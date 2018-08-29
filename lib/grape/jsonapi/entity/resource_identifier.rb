require 'bson'

module Grape
  module Jsonapi
    module Entity
      class ResourceIdentifier < Grape::Entity
        class << self
          attr_reader :type_plural
        end

        def self.inherited(subclass)
          class << subclass
            attr_accessor :custom_id_proc
          end
          super(subclass)
        end

        def self.root(plural, singular = nil, for_real = false)
          @type_plural = plural
          super(plural, singular) if for_real
        end

        def self.entity_id(attribute_name=nil, &block)
          self.custom_id_proc = if attribute_name != nil
            ->(capture) { capture.send(attribute_name.to_sym) }
          elsif block_given?
            block
          else
            raise ArgumentError.new('must provide an attribute name or a block')
          end
        end

        expose :id, format_with: :to_string
        expose :json_api_type, as: :type

        expose :meta, if: lambda { |instance, _options|
          (instance.respond_to? :meta) && (instance.meta.keys.count > 0)
        }

        format_with(:to_string) { |foo| foo.class == ::BSON::ObjectId ? foo.to_s : foo }

        private

        def id
          self.class.custom_id_proc.is_a?(Proc) ? self.class.custom_id_proc.call(object) : object.id
        end

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
