require 'aws-sdk'
require 'capistrano/dsl'
require 'byebug'

load File.expand_path('../tasks/elbas.rake', __FILE__)

def autoscale(groupname, *args)
  include Capistrano::DSL
  include Elbas::Aws::AutoScaling
  include Elbas::Aws::EC2

  autoscaling_group = autoscaling_resource.group(groupname)
  asg_instances = autoscaling_group.instances

  set :aws_autoscale_group, groupname

  asg_instances.each do |asg_instance|
    if asg_instance.health_status != 'Healthy'
      p "ELBAS: Skipping unhealthy instance #{instance.id}"
    else
      ec2_instance = ec2_resource.instance(asg_instance.id)
      hostname = ec2_instance.private_ip_address
      p "ELBAS: Adding server: #{hostname}"
      server(hostname, *args)
    end
  end

  if asg_instances.count > 0
    after('deploy', 'elbas:scale')
  else
    p 'ELBAS: AMI could not be created because no running instances were found.\
      Is your autoscale group name correct?'
  end
end
