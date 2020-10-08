module Elbas
  module AWS
    class Instance < Base
      STATE_RUNNING = 16.freeze

      attr_reader :aws_counterpart, :id, :state

      def initialize(id, public_dns, private_dns, state)
        @id = id
        @public_dns = public_dns
        @private_dns = private_dns
        @state = state
        @aws_counterpart = aws_namespace::Instance.new id, client: aws_client
      end

      def hostname
          if @public_dns.nil? || @public_dns.empty?
              @private_dns
          else
              @public_dns
          end
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
