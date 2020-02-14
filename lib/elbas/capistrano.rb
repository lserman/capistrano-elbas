require 'capistrano/dsl'

load File.expand_path("../tasks/elbas.rake", __FILE__)

def autoscale(groupname, properties = {})
  include Capistrano::DSL
  include Elbas::Logger

  set :aws_autoscale_group_name, groupname

  skip_ami = properties.delete(:skip_ami)
  hostname_method = properties.delete(:hostname_method)

  set :hostname_method, hostname_method

  asg = Elbas::AWS::AutoscaleGroup.new groupname, hostname_method
  instances = asg.instances.running

  instances.each.with_index do |instance, i|
    info "Adding server: #{instance.hostname}"

    props = nil
    props = yield(instance, i) if block_given?
    props ||= properties

    server instance.hostname, props
  end

  if instances.any?
    unless skip_ami
      after 'deploy', 'elbas:deploy'
    end
  else
    error <<~MESSAGE
      Could not create AMI because no running instances were found in the specified
      AutoScale group. Ensure that the AutoScale group name is correct and that
      there is at least one running instance attached to it.
    MESSAGE
  end
end
