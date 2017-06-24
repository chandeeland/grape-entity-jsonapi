module Grape
  module Jsonapi
    class Document
      def self.top(resource)
        Class.new(Grape::Jsonapi::Entity::Top).tap do |klass|
          klass.expose :data,
                       using: resource,
                       unless: ->(instance, _options) { instance.respond_to? :errors }
        end
      end
    end
  end
end
