module Elbas
  # Provides basic AWS resource methods
  class AWSResource
    include Capistrano::DSL
    include Elbas::Aws::AutoScaling
    include Elbas::Aws::EC2
    include Elbas::Retryable
    include Logger

    attr_reader :aws_counterpart

    def cleanup(&_block)
      items = trash || []
      yield
      destroy items
      self
    end

    private

    def base_ec2_instance
      autoscaling_group.instances[0]
    end

    def environment
      fetch(:rails_env, 'production')
    end

    def timestamp(str)
      "#{str}-#{Time.now.to_i}"
    end

    def deployed_with_elbas?(resource)
      return false if resource.tags.empty?
      resource.tags.any? { |k| k.key == 'Deployed-with' && k.value == 'ELBAS' } &&
        resource.tags.any? { |k| k.key == 'ELBAS-Deploy-group' && k.value == autoscaling_group_name }
    end
  end
end
