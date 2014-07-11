require 'minitest/autorun'
require 'minitest/reporters'
require 'webmock'

require 'capistrano/all'

require 'elbas'
require 'elbas/aws'
require 'elbas/ami'
require 'elbas/launch_configuration'

Minitest::Reporters.use!

WebMock.disable_net_connect!
load File.expand_path("../stubs.rb", __FILE__)