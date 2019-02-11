module Elbas
  module AWS
    class Snapshot < Base
      attr_reader :id

      def initialize(id)
        @id = id
      end

      def delete
        aws_client.delete_snapshot snapshot_id: id if id
      end

      private
        def aws_namespace
          ::Aws::EC2
        end
    end
  end
end