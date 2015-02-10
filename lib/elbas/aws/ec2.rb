module Elbas
  module AWS
    module EC2
      extend ActiveSupport::Concern
      include Elbas::AWS::Credentials
      include Capistrano::DSL

      def ec2
        @_ec2 ||= ::AWS::EC2.new(credentials)
      end

    end
  end
end