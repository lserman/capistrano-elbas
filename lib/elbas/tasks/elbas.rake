require 'elbas'
include Elbas::Logger

namespace :elbas do
  task :ssh do
    include Capistrano::DSL

    info "SSH commands:"
    env.servers.to_a.each.with_index do |server, i|
      info "    #{i + 1}) ssh #{fetch(:user)}@#{server.hostname}"
    end
  end

  task :deploy do
    asg = Elbas::AWS::AutoscaleGroup.new fetch(:aws_autoscale_group_name)

    info "Creating AMI from a running instance..."
    ami = Elbas::AWS::AMI.create asg.instances.running.sample
    ami.tag 'ELBAS-Deploy-group', asg.name
    ami.tag 'ELBAS-Deploy-id', env.timestamp.to_i.to_s
    info  "Created AMI: #{ami.id}"

    info "Updating launch template with the new AMI..."
    launch_template = asg.launch_template.update ami
    info "Updated launch template, new default version = #{launch_template.version}"

    info "Cleaning up old AMIs..."
    keep = fetch(:elbas_keep_amis) || 5
    if ami.ancestors.count > keep
      amis = ami.ancestors.drop(keep)
      amis.each do |ancestor|
        info "Deleting old AMI: #{ancestor.id}"
        ancestor.delete
      end
      info "Deleted #{amis.count} old AMIs and keeping newest #{keep}"
    end

    info "Deployment complete!"
  end
end
