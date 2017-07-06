require 'grape/jsonapi/base_entity'

module Grape
  module Jsonapi
    module Entity
      class ResourceIdentifier < BaseEntity
        class << self
          attr_reader :type_plural
        end

        def self.root(plural, singular = nil, for_real = false)
          @type_plural = plural
          super(plural, singular) if for_real
        end

        expose :type

        expose :meta, if: lambda { |instance, _options|
          (instance.respond_to? :meta) && (instance.meta.keys.count > 0)
        }

        private

        # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity

        def type
          object.try(:type) ||
            (object.is_a? Hash) && object.fetch(:type, nil) ||
            (object.is_a? Hash) && object.fetch('type', nil) ||
            self.class.type_plural ||
            self.class.name.split('::').last.downcase.pluralize
        end
        # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity
      end
    end
  end
end
