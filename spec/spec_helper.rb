require 'webmock'
require 'capistrano/all'

ENV['AWS_REGION'] = 'us-east-1'
ENV['AWS_ACCESS_KEY_ID'] = 'test-access'
ENV['AWS_SECRET_ACCESS_KEY'] = 'test-secret'

require 'elbas'
require 'webmock/rspec'

# Hack for webmock-rspec-helper
Rails = Class.new do
  def self.root
    Pathname.new(__dir__).join('..')
  end
end

require 'webmock-rspec-helper'

WebMock.disable_net_connect!

Dir[File.join(File.expand_path('../..', __FILE__), 'spec', 'support', '**', '*.rb')].each { |f| require f }