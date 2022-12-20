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
    include Capistrano::DSL
    deploy_servers = env.filter(env.servers).map(&:hostname)

    fetch(:aws_autoscale_group_names).each do |aws_autoscale_group_name|
      info "Auto Scaling Group: #{aws_autoscale_group_name}"
      asg = Elbas::AWS::AutoscaleGroup.new aws_autoscale_group_name

      instances_in_current_deploy = asg.instances.running.select do |instance|
        hostname = instance.hostname
        deploy_servers.include?(hostname)        
      end

      unless instances_in_current_deploy.any?
        info "Auto Scaling Group #{aws_autoscale_group_name} skip AMI creation"
        next
      end

      info "Creating AMI from a running instance..."
      ami = Elbas::AWS::AMI.create instances_in_current_deploy.sample
      ami.tag 'ELBAS-Deploy-group', asg.name
      ami.tag 'ELBAS-Deploy-id', env.timestamp.to_i.to_s
      info  "Created AMI: #{ami.id}"

      info "Updating launch template with the new AMI..."
      launch_template = asg.launch_template.update ami
      info "Updated launch template, new default version = #{launch_template.version}"

      info "Cleaning up old AMIs..."
      ami.ancestors.each do |ancestor|
        info "Deleting old AMI: #{ancestor.id}"
        ancestor.delete
      end

      info "Deployment complete!"
    end
  end
end
