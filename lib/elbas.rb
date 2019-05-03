require 'capistrano/all'
require 'aws-sdk-autoscaling'
require 'aws-sdk-ec2'

require 'elbas/version'
require 'elbas/logger'
require 'elbas/retryable'

require 'elbas/errors/no_launch_template'

require 'elbas/aws/base'
require 'elbas/aws/taggable'
require 'elbas/aws/instance_collection'
require 'elbas/aws/instance'
require 'elbas/aws/autoscale_group'
require 'elbas/aws/launch_template'
require 'elbas/aws/ami'
require 'elbas/aws/snapshot'

module Elbas
end
