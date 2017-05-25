require 'bundler/setup'
Bundler.setup

require 'pry-byebug'
require 'grape_entity'
require 'grape-jsonapi_entity'

RSpec.configure(&:raise_errors_for_deprecations!)
