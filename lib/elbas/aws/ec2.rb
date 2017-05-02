module Elbas
  module Aws
    # Provide EC2 client and resource information
    module EC2
      extend ActiveSupport::Concern
      include Elbas::Aws::Credentials
      include Capistrano::DSL

      def ec2_resource
        @_ec2_resource ||= ::Aws::EC2::Resource.new(client: ec2_client)
      end

      def reset_ec2_objects
        @_ec2_resource = nil
      end

      private

      def ec2_client
        ::Aws::EC2::Client.new(credentials)
      end
    end
  end
end
