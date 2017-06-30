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
        expose :id do |instance, _options|
          self.try(:id) ? self.id : instance.id
        end

        expose :meta, if: lambda { |instance, _options|
          (instance.respond_to? :meta) && (instance.meta.keys.count > 0)
        }

        private

        # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
        def type
          object.try(:type) ||
            (object.is_a? Hash) && object.fetch(:type, nil) ||
            (object.is_a? Hash) && object.fetch('type', nil) ||
            self.try(:child).try(:type_plural) ||
            self.class.type_plural ||
            (self.class.try(:name) || 'no_type').split('::').last.underscore.pluralize
        end
        # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity
      end
    end
  end
end
