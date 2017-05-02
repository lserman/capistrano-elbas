# ELBAS (Elastic Load Balancer & AutoScaling)

ELBAS was written to ease the deployment of Rails applications to AWS AutoScale groups. ELBAS will:

- Deploy your code to each running instance connected to a given AutoScale group
- After deployment, create an AMI from one of the running instances
- Attach the AMI with the new code to a new AWS Launch Configuration
- Update your AutoScale group to use the new launch configuration
- Delete any old AMIs created by ELBAS
- Delete any old launch configurations created by ELBAS

This ensures that your current and future servers will be running the newly deployed code.

## Installation

`gem 'elbas'`

Add this statement to your Capfile:

`require 'elbas/capistrano'`

## Configuration

Below are the Capistrano configuration options with their defaults:

```ruby
set :aws_access_key_id,     ENV['AWS_ACCESS_KEY_ID']
set :aws_secret_access_key, ENV['AWS_SECRET_ACCESS_KEY']
set :aws_region,            ENV['AWS_REGION']

set :aws_no_reboot_on_create_ami, true
set :aws_autoscale_instance_size, 'm1.small'

set :aws_launch_configuration_detailed_instance_monitoring, true
set :aws_launch_configuration_associate_public_ip, true
```

## Usage

Instead of using Capistrano's `server` method, use `autoscale` instead in `deploy/production.rb` (or
whichever environment you're deploying to). Provide the name of your AutoScale group instead of a
hostname:

```ruby
autoscale 'production', user: 'apps', roles: [:app, :web, :db]
```

If you have multiple autoscaling groups to deploy to, specify each of them:

```ruby
autoscale 'asg-app', user: 'apps', roles: [:app, :web]
autoscale 'asg-db', user: 'apps', roles: [:db]
```

Similarly, if you are deploying to multiple regions:

```ruby
regions = %w(us-east-1 eu-west-1)

regions.each do |region|
  set :aws_region, region
  autoscale 'production', user: 'apps', roles: [:app, :web, :db]
end
```

That's it! Run `cap production deploy`. ELBAS will print the following log statements during your
deployment:

```
"ELBAS: Adding server: ec2-XX-XX-XX-XXX.compute-1.amazonaws.com"
"ELBAS: Creating EC2 AMI from i-123abcd"
"ELBAS: Created AMI: ami-123456"
"ELBAS: Creating an EC2 Launch Configuration for AMI: ami-123456"
"ELBAS: Created Launch Configuration: elbas-lc-ENVIRONMENT-UNIX_TIMESTAMP"
"ELBAS: Attaching Launch Configuration to AutoScale Group"
"ELBAS: Deleting old launch configuration: elbas-lc-production-123456"
"ELBAS: Deleting old image: ami-999999"
```
