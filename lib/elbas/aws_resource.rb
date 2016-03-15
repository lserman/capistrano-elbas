module Elbas
  class AWSResource
    include Capistrano::DSL
    include Elbas::AWS::AutoScaling
    include Elbas::AWS::EC2
    include Elbas::Retryable
    include Logger

    attr_reader :aws_counterpart

    def cleanup(&block)
      items = trash || []
      yield
      destroy items
      self
    end

    protected

      def base_ec2_instance
        @_base_ec2_instance ||= autoscale_group.ec2_instances.filter('instance-state-name', 'running').first
      end

      def environment
        fetch(:rails_env, 'production')
      end

      def timestamp(str)
        "#{str}-#{Time.now.to_i}"
      end

    private

      def deployed_with_elbas?(resource)
        resource.name =~ /ELBAS-#{environment}-#{$server_role}/
      end

  end
end
