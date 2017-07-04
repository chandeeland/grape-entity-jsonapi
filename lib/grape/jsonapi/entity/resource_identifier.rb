module Grape
  module Jsonapi
    module Entity
      class ResourceIdentifier < ::Grape::Entity
        class << self
          attr_reader :type_plural
          attr_accessor :formatter
        end

        def self.root(plural, singular = nil, for_real = false)
          @type_plural = plural
          super(plural, singular) if for_real
        end

        expose :type
        expose :id do |instance, _options|
          exposed_id = self.try(:id) || instance.try(:id) || id_exposer

          if self.class.try(:formatter) && self.class.try(:formatter).has_key?(:id_formatter)
            exposed_id = self.class.formatter[:id_formatter].call(object.send(:id))
          end

          exposed_id
        end

        expose :meta, if: lambda { |instance, _options|
          (instance.respond_to? :meta) && (instance.meta.keys.count > 0)
        }

        private

        # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity

        def id_exposer
          (object.is_a? Hash) && object.fetch(:id, nil) ||
          (object.is_a? Hash) && object.fetch('id', nil)
        end

        def type
          object.try(:type) ||
            (object.is_a? Hash) && object.fetch(:type, nil) ||
            (object.is_a? Hash) && object.fetch('type', nil) ||
            self.class.type_plural ||
            (self.class.try(:name) || 'no_type').split('::').last.underscore.pluralize
        end
        # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity
      end
    end
  end
end
