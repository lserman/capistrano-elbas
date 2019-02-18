module Elbas
  module AWS
    class Base
      include Capistrano::DSL

      attr_reader :aws_counterpart

      def aws_client(namespace = aws_namespace)
        @aws_client ||= begin
          options = {}
          options[:region] = aws_region if aws_region
          options[:credentials] = aws_credentials if aws_credentials.set?

          namespace::Client.new options
        end
      end

      def aws_credentials
        fetch :aws_credentials, ::Aws::Credentials.new(aws_access_key, aws_secret_key)
      end

      def aws_access_key
        fetch :aws_access_key
      end

      def aws_secret_key
        fetch :aws_secret_key
      end

      def aws_region
        fetch :aws_region
      end

      def self.aws_client(namespace = aws_namespace)
        Base.new.aws_client namespace
      end
    end
  end
end