module Grape
  module Jsonapi
    class Document
      def self.top(resource)
        name = "Top#{resource.name.demodulize}"

        Class.new(Grape::Jsonapi::Entity::Top).tap do |klass|
          const_set(name, klass)

          klass.expose :data,
                       using: resource,
                       unless: Jsonapi::Exposer.field_exists?(:errors)
        end
      end
    end
  end
end
