require 'elbas'

namespace :elbas do
  task :scale do
    set :aws_access_key_id,     fetch(:aws_access_key_id,     ENV['AWS_ACCESS_KEY_ID'])
    set :aws_secret_access_key, fetch(:aws_secret_access_key, ENV['AWS_SECRET_ACCESS_KEY'])

    Elbas::AMI.create do |ami|
      p "ELBAS: Created AMI: #{ami.aws_counterpart.id}"
      Elbas::LaunchConfiguration.create(ami) do |lc|
        p "ELBAS: Created Launch Configuration: #{lc.aws_counterpart.name}"
        lc.attach_to_autoscale_group!
      end
    end
  end

  task :list do
    set :aws_access_key_id,     fetch(:aws_access_key_id,     ENV['AWS_ACCESS_KEY_ID'])
    set :aws_secret_access_key, fetch(:aws_secret_access_key, ENV['AWS_SECRET_ACCESS_KEY'])

    include Capistrano::DSL
    include Elbas::AWS::AutoScaling

    puts "ELBAS: ASG NAME: #{autoscale_group_name}"

    autoscale_group   = autoscaling.groups[autoscale_group_name]
    running_instances = autoscale_group.ec2_instances.filter('instance-state-name', 'running')

    running_instances.each do |ami|
      puts "ELBAS: ASG AMI: #{ami.id} (#{ami.private_ip_address})"
    end

  end
end
