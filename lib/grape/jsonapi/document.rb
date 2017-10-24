module Grape
  module Jsonapi
    class Document
      def self.top(resource)
        Class.new(Grape::Jsonapi::Entity::Top).tap do |klass|
          const_set(resource.name.demodulize, klass)

          klass.expose :data,
                       using: resource,
                       unless: Jsonapi::Exposer.field_exists?(:errors)
        end
      end
    end
  end
end
