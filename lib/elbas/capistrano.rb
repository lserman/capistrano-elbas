require 'aws-sdk'
require 'capistrano/dsl'

load File.expand_path('../tasks/elbas.rake', __FILE__)

def autoscale(groupname, *args)
  include Capistrano::DSL
  include Elbas::Aws::AutoScaling
  include Elbas::Aws::EC2

  autoscaling_group = autoscaling_resource.group(groupname)
  asg_instances = autoscaling_group.instances

  set :aws_autoscale_group, groupname
  region = fetch(:aws_region)
  regions = fetch(:regions, {})
  (regions[region] ||= []) << groupname
  set :regions, regions

  asg_instances.each do |asg_instance|
    if asg_instance.health_status != 'Healthy'
      puts "ELBAS: Skipping unhealthy instance #{instance.id}"
    else
      ec2_instance = ec2_resource.instance(asg_instance.id)
      hostname = ec2_instance.private_ip_address
      puts "ELBAS: Adding server: #{hostname}"
      server(hostname, *args)
    end
  end

  if asg_instances.count.positive?
    after('deploy', 'elbas:scale')
  else
    puts 'ELBAS: AMI could not be created because no running instances were found.\
      Is your autoscale group name correct?'
  end

  reset_autoscaling_objects
  reset_ec2_objects
end
