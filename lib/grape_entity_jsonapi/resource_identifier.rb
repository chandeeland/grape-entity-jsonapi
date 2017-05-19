module GrapeEntityJsonapi
  class ResourceIdentifier < Grape::Entity
    expose :type
    expose :id

    expose :meta, if: meta.keys.count > 0

    private

    def type
      # self.class.name.downclase.pluralize
      collection_root
    end
  end
end
