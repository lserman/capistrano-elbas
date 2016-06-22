require 'aws-sdk-v1'
require 'capistrano/dsl'

load File.expand_path("../tasks/elbas.rake", __FILE__)

def autoscale(groupname, *args)
  include Capistrano::DSL
  include Elbas::AWS::AutoScaling

  autoscale_group   = autoscaling.groups[groupname]
  running_instances = autoscale_group.ec2_instances.filter('instance-state-name', 'running')
  protected_instances = fetch(:aws_autoscale_protected_instances, [])
  if protected_instances.empty?
    base_instance = running_instances.first
  else
    base_instance = running_instances.select { |ins| !protected_instances.include?(ins.id) }.first
  end

  set :aws_autoscale_group, groupname

  running_instances.each do |instance|
    hostname = instance.dns_name || instance.private_ip_address
    p "ELBAS: Adding server: #{hostname}"
    server(hostname, *args)
  end


  if base_instance.nil?
    p "ELBAS: AMI could not be created because no running instances were found. Is your autoscale group name correct?"
  else
    after('deploy', 'elbas:scale')
  end
end
