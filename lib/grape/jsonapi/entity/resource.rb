require 'grape/jsonapi/entity/resource_identifier'

module Grape
  module Jsonapi
    module Entity
      class Resource < ResourceIdentifier
        class << self
          def attributes_exposure
            @attributes_exposure ||= begin
              ::Grape::Entity::Exposure.new(:attributes, nesting: true).tap do |attributes|
                root_exposure.nested_exposures << attributes
              end
            end
          end

          def relationships_exposure
            @relationships_exposure ||= begin
              ::Grape::Entity::Exposure.new(:relationships, nesting: true).tap do |relationship|
                root_exposure.nested_exposures << relationship
              end
            end
          end
        end

        def self.root(plural, _singular)
          @type_plural = plural
        end

        # expose a field inside of :attributes stanza
        def self.attribute(*args, &block)
          _expose_inside(attributes_exposure, args, block)
        end

        # @TODO implement compound-documents
        def self.nest(name, options = {})
          link_opts = options.merge(using: Grape::Jsonapi::Entity::ResourceIdentifier)

          relation = ::Grape::Entity::Exposure.new(name, nesting: true)

          relationships_exposure.nested_exposures << relation

          _expose_inside(relation, ['data', link_opts], nil)
        end

        def self._expose_inside(new_nesting_stack, args, block)
          old_nesting_stack = @nesting_stack
          @nesting_stack = [new_nesting_stack]
          expose(*args) unless block_given?
          expose(*args, &block) if block_given?
          @nesting_stack = old_nesting_stack
        end

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
