module Grape
  module Jsonapi
    module Entity
      class ResourceIdentifier < ::Grape::Entity
        class << self
          attr_reader :type_plural
        end

        def self.root(plural, singular = nil, for_real = false)
          @type_plural = plural
          super(plural, singular) if for_real
        end

        expose :type
        expose :id

        expose :meta, if: lambda { |instance, _options|
          (instance.respond_to? :meta) && (instance.meta.keys.count > 0)
        }

        private

        def type
          object.try(:type) ||
            (object.is_a? Hash) && object.fetch(:type, nil) ||
            (object.is_a? Hash) && object.fetch('type', nil) ||
            self.class.type_plural ||
            self.class.name.split('::').last.downcase.pluralize
        end
      end
    end
  end
end
