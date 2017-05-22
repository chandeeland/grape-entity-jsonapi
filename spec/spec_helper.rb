require 'bundler/setup'
Bundler.setup

require 'pry-byebug'
require 'grape_entity'
require 'grape_entity_jsonapi'

RSpec.configure(&:raise_errors_for_deprecations!)
