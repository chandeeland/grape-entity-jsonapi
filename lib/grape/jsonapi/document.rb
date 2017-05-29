module Grape
  module Jsonapi
    class Document
      def self.top(resource)
        Class.new(Grape::Jsonapi::Entity::Top).tap do |klass|
          klass.expose :data,
                       using: resource,
                       unless: ->(instance, _options) { instance.errors.present? }
        end
      end
    end
  end
end
