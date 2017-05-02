module Elbas
  module Aws
    module Credentials
      extend ActiveSupport::Concern
      include Capistrano::DSL

      def credentials
        _credentials = {
          access_key_id:     fetch(:aws_access_key_id,     ENV['AWS_ACCESS_KEY_ID']),
          secret_access_key: fetch(:aws_secret_access_key, ENV['AWS_SECRET_ACCESS_KEY']),
          region:            fetch(:aws_region,            ENV['AWS_REGION'])
        }

        _credentials.merge! region: fetch(:aws_region) if fetch(:aws_region)
        _credentials
      end
    end
  end
end
