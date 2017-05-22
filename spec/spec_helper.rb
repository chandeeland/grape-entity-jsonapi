require 'bundler/setup'
Bundler.setup

require 'pry-byebug'
require 'grape_entity'
require 'grape_entity_jsonapi'

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
end
