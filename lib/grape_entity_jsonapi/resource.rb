module GrapeEntityJsonapi
  class Resource < Grape::Jsonapi::ResourceIdentifier

    class << self
      def attributes_exposure
        @attributes_exposure ||= Exposure.new(:attributes, nesting: true).tap do |attributes|
          data_exposure.nested_exposures << attributes
        end
      end

      def relationships_exposure
        @relationships_exposure ||= Exposure.new(:relationships, nesting: true).tap do |relationship|
          relationship.nested_exposures << Exposure.new(:data, nesting: true)
          data_exposure.nested_exposures << relationship
        end
      end
    end

    # expose a field inside of :attributes stanza
    def self.attribute(*args, &block)
      old_nesting_stack = @nesting_stack
      @nesting_stack = [ attributes_exposure ]
      expose(*args, block)
      @nesting_stack = old_nesting_stack
    end

    # expose a nested resource fully nested under :relationships
    def self.nest(*args, &block)
      old_nesting_stack = @nesting_stack
      @nesting_stack = [ relationships_exposure.find_exposure(:data) ]
      expose(*args, block)
      @nesting_stack = old_nesting_stack
    end

    # @TODO implement compound-documents
    # # expose a link to a resource under :relationships
    # # where the fully object will be sideloaded under include:
    # def self.sideload(*args, &block)
    #   old_nesting_stack = @nesting_stack
    #   @nesting_stack = [ relationships_exposure.find_exposure(:data) ]
    #   expose(*args, block)
    #   @nesting_stack = old_nesting_stack
    # end

    # @TODO implement links
    # expose :links, type: Hash do
    #   expose :link_self, as: :self
    #   expose :link_related, as: :related
    # end
    #
    # def link_self
    #   "/#{root}/#{id}"
    # end
    #
    # def link_related
    #   "/#{collection_root}"
    # end
  end
end
