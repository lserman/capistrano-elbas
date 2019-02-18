module Elbas
  module AWS
    class Snapshot < Base
      attr_reader :id

      def initialize(id)
        @id = id
      end

      def delete
        return unless id
        aws_client.delete_snapshot snapshot_id: id
      end

      private
        def aws_namespace
          ::Aws::EC2
        end
    end
  end
end