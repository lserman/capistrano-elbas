# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'elbas/version'

Gem::Specification.new do |spec|
  spec.name          = "elbas"
  spec.version       = Elbas::VERSION
  spec.authors       = ["Logan Serman"]
  spec.email         = ["logan.serman@metova.com"]
  spec.summary       = 'Capistrano plugin for deploying to AWS ASGroups.'
  spec.description   = "#{spec.summary}. Deploys to all instances in a group, creates a fresh AMI post-deploy, and attaches the AMI to your ASGroup."
  spec.homepage      = "http://github.com/metova/elbas"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "minitest-reporters"
  spec.add_development_dependency "webmock"

  spec.add_dependency 'aws-sdk', '~> 1'
  spec.add_dependency 'capistrano', '> 3.0.0'

end
