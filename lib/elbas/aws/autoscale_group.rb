module Elbas
  module AWS
    class AutoscaleGroup < Base
      attr_reader :name

      def initialize(name)
        @name = name
        @aws_counterpart = query_autoscale_group_by_name(name)
      end

      def instance_ids
        aws_counterpart.instances.map(&:instance_id)
      end

      def instances
        InstanceCollection.new(instance_ids).running
      end

      def launch_template
        raise Elbas::Errors::NoLaunchTemplate unless aws_counterpart.launch_template

        LaunchTemplate.new(
          aws_counterpart.launch_template.launch_template_id,
          aws_counterpart.launch_template.launch_template_name,
          aws_counterpart.launch_template.version,
        )
      end

      private
        def aws_namespace
          ::Aws::AutoScaling
        end

        def query_autoscale_group_by_name(name)
          aws_client
            .describe_auto_scaling_groups(auto_scaling_group_names: [name])
            .auto_scaling_groups
            .first
        end

    end
  end
end