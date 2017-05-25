require 'grape/jsonapi/entity/resource_identifier'

module Grape
  module Jsonapi
    module Entity
      class Resource < ResourceIdentifier
        class << self
          def attributes_exposure
            @attributes_exposure ||= ::Grape::Entity::Exposure.new(:attributes, nesting: true).tap do |attributes|
              root_exposure.nested_exposures << attributes
            end
          end

          def relationships_exposure
            @relationships_exposure ||= begin
        ::Grape::Entity::Exposure.new(:relationships, nesting: true).tap do |relationship|
          relationship.nested_exposures << ::Grape::Entity::Exposure.new(:data, nesting: true)
          root_exposure.nested_exposures << relationship
        end
      end
          end
        end

        # expose a field inside of :attributes stanza
        def self.attribute(*args, &block)
          _expose_inside(attributes_exposure, args, block)
        end

        # expose a nested resource fully nested under :relationships
        def self.nest(*args, &block)
          _expose_inside(relationships_exposure.find_nested_exposure(:data), args, block)
        end

        def self._expose_inside(new_nesting_stack, args, block)
          old_nesting_stack = @nesting_stack
          @nesting_stack = [new_nesting_stack]
          expose(*args) unless block_given?
          expose(*args, &block) if block_given?
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
  end
end
