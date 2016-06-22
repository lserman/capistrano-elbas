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

    private
      def base_ec2_instance
        instances = autoscale_group.ec2_instances.filter('instance-state-name', 'running')
        protected_instances = fetch(:aws_autoscale_protected_instances, [])
        instances = instances.select { |ins| !protected_instances.include?(ins.id) } unless protected_instances.empty?
        @_base_ec2_instance ||= instances.first
      end

      def environment
        fetch(:rails_env, 'production')
      end

      def timestamp(str)
        "#{str}-#{Time.now.to_i}"
      end

      def deployed_with_elbas?(resource)
        resource.tags['Deployed-with'] == 'ELBAS' &&
          resource.tags['ELBAS-Deploy-group'] == autoscale_group_name
      end
  end
end
