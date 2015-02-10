require 'webmock'
require 'capistrano/all'
require 'elbas'
require 'webmock/rspec'

WebMock.disable_net_connect!

Dir[File.join(File.expand_path('../..', __FILE__), 'spec', 'support', '**', '*.rb')].each { |f| require f }

module WebMock
  module RSpec
    module Helper

      def webmock(method, mocks = {})
        mocks.each do |regex, filename|
          status = filename[/\.(\d+)\./, 1] || 200
          body = File.read File.join(File.expand_path('../..', __FILE__), 'spec', 'support', 'stubs', filename)
          if block_given? && with_options = yield
            WebMock.stub_request(method, regex).with(with_options).to_return status: status.to_i, body: body
          else
            WebMock.stub_request(method, regex).to_return status: status.to_i, body: body
          end
        end
      end

    end
  end
end

RSpec.configure do |config|
  config.include WebMock::RSpec::Helper
end