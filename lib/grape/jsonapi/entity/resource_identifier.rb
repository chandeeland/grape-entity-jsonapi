module Grape
  module Jsonapi
    module Entity
      class ResourceIdentifier < ::Grape::Entity
        expose :type
        expose :id

        expose :meta, if: lambda { |instance, _options|
          (instance.respond_to? :meta) && (instance.meta.keys.count > 0)
        }

        private

        def type
          # self.class.name.downclase.pluralize
          collection_root
        end
      end
    end
  end
end
