module Elbas
  module Aws
    # Provide AutoScaling client, resource, and group information
    module AutoScaling
      extend ActiveSupport::Concern
      include Elbas::Aws::Credentials
      include Capistrano::DSL

      def autoscaling_client
        @_autoscaling_client ||= ::Aws::AutoScaling::Client.new(credentials)
      end

      def autoscaling_resource
        @_autoscaling_resource ||= ::Aws::AutoScaling::Resource.new(client: autoscaling_client)
      end

      def autoscaling_group
        @_autoscaling_group ||= autoscaling_resource.group(autoscaling_group_name)
      end

      def autoscaling_group_name
        fetch(:aws_autoscale_group)
      end

      def reset_autoscaling_objects
        @_autoscaling_client = nil
        @_autoscaling_resource = nil
        @_autoscaling_group = nil
      end
    end
  end
end
