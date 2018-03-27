module Grape
  module Jsonapi
    class Document
      def self.top(resource)
        instance.top(resource)
      end

      def self.resource_id(name, entity)
        instance.resource_id(name, entity)
      end

      def self.instance
        @instance ||= new
      end

      def top(resource)
        name = "Top#{resource.name.demodulize}"
        @top[resource.name] ||= Class.new(Grape::Jsonapi::Entity::Top).tap do |klass|
          Grape::Jsonapi::Document.const_set(name, klass)

          klass.expose :data,
                       using: resource,
                       unless: Jsonapi::Exposer.field_exists?(:errors)
        end
      end

      def resource_id(label, entity)
        name = (name_from_type(entity) || name_from_class(entity) || label).to_s
        @resource_id[name] ||= Class.new(Grape::Jsonapi::Entity::ResourceIdentifier).tap do |klass|
          Grape::Jsonapi::Document.const_set("ResourceId#{name.demodulize.camelize}", klass)
          klass.root(name.downcase.pluralize)
        end
      end

      private

      def initialize
        @resource_id = {}
        @top = {}
      end

      def name_from_type(entity)
        return entity.type if entity.respond_to?(:type)
      end

      def name_from_class(entity)
        return entity.name.split('::').last unless entity.nil?
      end
    end
  end
end
