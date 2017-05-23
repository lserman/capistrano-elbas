require 'elbas'

namespace :elbas do
  task :scale do
    set :aws_access_key_id,     fetch(:aws_access_key_id,     ENV['AWS_ACCESS_KEY_ID'])
    set :aws_secret_access_key, fetch(:aws_secret_access_key, ENV['AWS_SECRET_ACCESS_KEY'])

    # Iterate over relevant regions
    regions = fetch(:regions)
    regions.keys.each do |region|
      set :aws_region, region
      # Iterate over relevant ASGs
      regions[region].each do |asg|
        set :aws_autoscale_group, asg
        Elbas::AMI.create do |ami|
          puts "ELBAS: Created AMI: #{ami.aws_counterpart.id} from region #{region} in ASG #{asg}"
          Elbas::LaunchConfiguration.create(ami) do |lc|
            puts "ELBAS: Created Launch Configuration: #{lc.aws_counterpart.name} from region #{region} in ASG #{asg}"
            lc.attach_to_autoscale_group!
          end # LC
        end # AMI
      end # ASG
    end # region
  end # scale
end
