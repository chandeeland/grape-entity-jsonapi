
# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'grape_entity_jsonapi/version'

Gem::Specification.new do |s|
  s.name          = 'grape-entity-jsonapi'
  s.version       = GrapeEntityJsonapi::VERSION
  s.platform      = Gem::Platform::RUBY
  s.date          = '2017-05-18'
  s.summary       = 'Json API v1.0 compliant sugar for grape entities'
  s.description   = ''
  s.authors       = ['David Chan']
  s.email         = 'chand@chandeeland.org'
  s.license       = 'MIT'

  s.add_runtime_dependency 'grape-entity', '~> 0.6', '>=0.6.0'

  s.add_development_dependency 'bundler', '~> 1.14'
  s.add_development_dependency 'rake', ' ~> 12.0'
  s.add_development_dependency 'rubocop', '~> 0.48'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'rack-test', '~> 0.6'
  s.add_development_dependency 'pry', '~> 0.10' unless RUBY_PLATFORM.eql?('java') || RUBY_ENGINE.eql?('rbx')
  s.add_development_dependency 'pry-byebug', '~> 3.4' unless RUBY_PLATFORM.eql?('java') || RUBY_ENGINE.eql?('rbx')

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec}/*`.split("\n")
  s.require_paths = ['lib']
end
