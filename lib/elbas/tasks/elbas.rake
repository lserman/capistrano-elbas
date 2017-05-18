require 'elbas'

namespace :elbas do
  task :scale do
    set :aws_access_key_id,     fetch(:aws_access_key_id,     ENV['AWS_ACCESS_KEY_ID'])
    set :aws_secret_access_key, fetch(:aws_secret_access_key, ENV['AWS_SECRET_ACCESS_KEY'])

    # Iterate over relevant regions
    regions = fetch(:regions)
    regions.keys.each do |region|
      set :aws_region, region
      Elbas::AMI.create do |ami|
        p "ELBAS: Created AMI: #{ami.aws_counterpart.id} from region #{region} in ASG #{regions[region].first}"
        Elbas::LaunchConfiguration.create(ami) do |lc|
          p "ELBAS: Created Launch Configuration: #{lc.aws_counterpart.name} from region #{region} in ASG #{regions[region].first}"
          lc.attach_to_autoscale_group!
        end
      end
    end
  end
end
