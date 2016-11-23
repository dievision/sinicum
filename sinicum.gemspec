# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sinicum/version"

Gem::Specification.new do |s|
  s.name        = "sinicum"
  s.version     = Sinicum::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Dievision GmbH"]
  s.email       = ["info@dievision.de"]
  s.homepage    = "http://github.com/dievision/sinicum"
  s.summary     = %q{Use Magnolia as a CMS backend in a Rails application}
  s.description = %q{Provides the necessary functionality to work with Magnolia-managed content in a Rails application.}

  s.add_dependency('rails', '~> 4.2', '< 5.0')
  s.add_dependency('httpclient', '~> 2.7')
  s.add_dependency('multi_json', '~> 1.11')
  s.add_development_dependency('rspec-rails', '~> 3.4')
  s.add_development_dependency('test-unit')
  s.add_development_dependency('yard')
  s.add_development_dependency('webmock')
  s.add_development_dependency('rubocop')
  s.add_development_dependency('codeclimate-test-reporter', '~> 0.6')

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
