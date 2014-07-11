require 'elbas'
require 'elbas/aws'
require 'elbas/ami'
require 'elbas/launch_configuration'

namespace :elbas do
  task :scale do
    set :aws_access_key_id,     fetch(:aws_access_key_id,     ENV['AWS_ACCESS_KEY_ID'])
    set :aws_secret_access_key, fetch(:aws_secret_access_key, ENV['AWS_SECRET_ACCESS_KEY'])

    Elbas::AMI.create do |ami|
      p "ELBAS: Created AMI: #{ami.id}"
      Elbas::LaunchConfiguration.create(ami) do |lc|
        p "ELBAS: Created Launch Configuration: #{lc.name}"
        lc.attach_to_asgroup!
      end
    end
  end
end
