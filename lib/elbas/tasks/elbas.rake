require 'elbas'
include Elbas::Logger

namespace :elbas do
  task :deploy do
    asg = Elbas::AWS::AutoscaleGroup.new fetch(:aws_autoscale_group_name)

    info "Creating AMI from a running instance..."
    ami = Elbas::AWS::AMI.create asg.instances.sample
    ami.tag 'ELBAS-Deploy-group', asg.name
    ami.tag 'ELBAS-Deploy-id', timestamp
    info  "Created AMI: #{ami.id}"

    info "Updating launch template with the new AMI..."
    launch_template = asg.launch_template.update ami
    info "Updated launch template, new default version = #{launch_template.version}"

    info "Cleaning up old AMIs (< #{timestamp})..."
    Elbas::AWS::AMI.filter('ELBAS-Deploy-group' => asg.name).each do |other|

    ami.ancestors.each do |ami|
      info "Deleting old AMI: #{ancestor.id}"
      # ancestor.delete
    end

    info "Deployment complete!"
  end
end
