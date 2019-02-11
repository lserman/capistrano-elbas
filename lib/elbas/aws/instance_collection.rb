module Elbas
  module AWS
    class InstanceCollection < Base
      attr_reader :instances

      def initialize(ids)
        @ids = ids
        @instances = query_instances_by_ids(ids).map do |i|
          Instance.new(i.instance_id, i.public_dns_name, i.state.code)
        end
      end

      def running
        instances.select(&:running?)
      end

      private
        def aws_namespace
          ::Aws::EC2
        end

        def query_instances_by_ids(ids)
          aws_client
            .describe_instances(instance_ids: @ids)
            .reservations[0]
            .instances
        end
    end
  end
end