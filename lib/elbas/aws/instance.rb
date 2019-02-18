module Elbas
  module AWS
    class Instance
      STATE_RUNNING = 16.freeze

      attr_reader :aws_counterpart, :id, :state

      def initialize(id, public_dns, state)
        @id = id
        @public_dns = public_dns
        @state = state
        @aws_counterpart = ::Aws::EC2::Instance.new id
      end

      def hostname
        @public_dns
      end

      def running?
        state == STATE_RUNNING
      end
    end
  end
end
