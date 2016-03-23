module Elbas
  module AWS
    module AutoScaling
      extend ActiveSupport::Concern
      include Elbas::AWS::Credentials
      include Capistrano::DSL

      def autoscaling
        @_autoscaling ||= ::AWS::AutoScaling.new(credentials)
      end

      def autoscale_group
        @_autoscale_group ||= autoscaling.groups[autoscale_group_name]
      end

      def autoscale_group_name
        fetch(:aws_autoscale_group)
      end
    end
  end
end
