module Elbas
  module AWS
    class Instance < Base
      STATE_RUNNING = 16.freeze

      attr_reader :aws_counterpart, :id, :state, :hostname

      def initialize(id, hostname, state)
        @id = id
        @hostname = hostname
        @state = state
        @aws_counterpart = aws_namespace::Instance.new id, client: aws_client
      end

      def running?
        state == STATE_RUNNING
      end

      private
        def aws_namespace
          ::Aws::EC2
        end
    end
  end
end
