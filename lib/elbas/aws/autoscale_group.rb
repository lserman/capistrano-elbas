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
        InstanceCollection.new instance_ids
      end

      def launch_template
        lts = aws_launch_template || aws_launch_template_specification
        raise Elbas::Errors::NoLaunchTemplate unless lts

        LaunchTemplate.new(
          lts.launch_template_id,
          lts.launch_template_name,
          lts.version
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

        def aws_launch_template
          aws_counterpart.launch_template
        end

        def aws_launch_template_specification
          aws_counterpart.mixed_instances_policy&.launch_template
            &.launch_template_specification
        end
    end
  end
end
