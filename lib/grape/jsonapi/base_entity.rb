require 'bson'

module Grape
  module Jsonapi
    class BaseEntity < Grape::Entity
      expose :id, :format_with => :to_string

      format_with(:to_string) { |foo| foo.class == ::BSON::ObjectId ? foo.to_s : foo }
    end
  end
end