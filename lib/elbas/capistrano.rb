require 'aws-sdk'
require 'capistrano/dsl'

load File.expand_path("../tasks/elbas.rake", __FILE__)

def autoscale(groupname, *args)
  include Capistrano::DSL

  asgroup = autoscaling.groups[groupname]
  set :aws_autoscale_group, groupname

  asgroup.ec2_instances.filter('instance-state-name', 'running').each do |instance|
    hostname = instance.dns_name || instance.private_ip_address
    p "ELBAS: Adding server: #{hostname}"
    server(hostname, *args)
  end

  after('deploy', 'elbas:scale')
end

private

def autoscaling
  @_autoscaling ||= AWS::AutoScaling.new \
    access_key_id: fetch(:aws_access_key_id, ENV['AWS_ACCESS_KEY_ID']),
    secret_access_key: fetch(:aws_secret_access_key, ENV['AWS_SECRET_ACCESS_KEY'])
end
