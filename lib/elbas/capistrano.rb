require 'aws-sdk'
require 'capistrano/dsl'

load File.expand_path("../tasks/elbas.rake", __FILE__)

def autoscale(groupname, *args)
  include Capistrano::DSL
  include Elbas::AWS::AutoScaling

  autoscale_group = autoscaling.groups[groupname]
  set :aws_autoscale_group, groupname

  autoscale_group.ec2_instances.filter('instance-state-name', 'running').each do |instance|
    hostname = instance.dns_name || instance.private_ip_address
    p "ELBAS: Adding server: #{hostname}"
    server(hostname, *args)
  end

  after('deploy', 'elbas:scale')
end
