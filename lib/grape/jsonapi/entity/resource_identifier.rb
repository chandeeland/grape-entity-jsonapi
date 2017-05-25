module Grape
  module Jsonapi
    module Entity
      class ResourceIdentifier < ::Grape::Entity
        class << self
          def type_plural
            @type_plural ||= name.downcase.pluralize
          end
        end

        def self.root(plural, _singular)
          @type_plural = plural
          super('data')
        end

        expose :type
        expose :id

        expose :meta, if: lambda { |instance, _options|
          (instance.respond_to? :meta) && (instance.meta.keys.count > 0)
        }

        private

        def type
          (Delegator.new object).delegate(:type) || self.class.type_plural
        end
      end
    end
  end
end
