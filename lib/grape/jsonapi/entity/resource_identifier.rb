require 'bson'

module Grape
  module Jsonapi
    module Entity
      class ResourceIdentifier < Grape::Entity
        class << self
          attr_reader :type_plural
        end

        def self.root(plural, singular = nil, for_real = false)
          @type_plural = plural
          super(plural, singular) if for_real
        end

        expose :id, format_with: :to_string
        expose :json_api_type, as: :type

        expose :meta, if: lambda { |instance, _options|
          (instance.respond_to? :meta) && (instance.meta.keys.count > 0)
        }

        format_with(:to_string) { |foo| foo.class == ::BSON::ObjectId ? foo.to_s : foo }

        private

        # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity

        def json_api_type
          object.try(:json_api_type) ||
            (object.is_a? Hash) && object.fetch(:json_api_type, nil) ||
            (object.is_a? Hash) && object.fetch('json_api_type', nil) ||
            self.class.type_plural ||
            self.class.name.split('::').last.downcase.pluralize
        end
        # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity
      end
    end
  end
end
