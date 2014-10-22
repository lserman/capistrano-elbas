require 'aws-sdk'

module Elbas
  class AWS
    include Capistrano::DSL

    attr_reader :aws_counterpart

    def cleanup(&block)
      items = garbage || []
      yield
      destroy items
      self
    end

    def info(message)
      p "ELBAS: #{message}"
    end

    def method_missing(_method, *args, &block)
      aws_counterpart.send _method, *args
    end

    protected

      def autoscaling
        @_autoscaling ||= ::AWS::AutoScaling.new(credentials)
      end

      def ec2
        @_ec2 ||= ::AWS::EC2.new(credentials)
      end

      def asgroup
        @_asgroup ||= autoscaling.groups[fetch(:aws_autoscale_group)]
      end

      def base_ec2_instance
        @_base_ec2_instance ||= asgroup.ec2_instances.filter('instance-state-name', 'running').first
      end

      def environment
        fetch(:rails_env, 'production')
      end

      def timestamp(str)
        "#{str}-#{Time.now.to_i}"
      end

    private

      def credentials
        { 
          access_key_id: fetch(:aws_access_key_id), 
          secret_access_key: fetch(:aws_secret_access_key), 
          region: fetch(:aws_region)
        }
      end

  end
end
