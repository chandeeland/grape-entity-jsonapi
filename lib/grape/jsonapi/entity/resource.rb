require 'grape/jsonapi/entity/resource_identifier'

module Grape
  class Entity
    OPTIONS = %i[
          rewrite as if unless using with proc documentation format_with safe attr_path if_extras unless_extras merge tracker
        ].to_set.freeze
  end

  module Jsonapi
    module Entity
      class Resource < ResourceIdentifier

        # OPTIONS = %i[
        #       rewrite as if unless using with proc documentation format_with safe attr_path if_extras unless_extras merge tracker
        #     ].to_set.freeze

        class << self
          def attributes_exposure
            @attributes_exposure ||= begin
              ::Grape::Entity::Exposure.new(:attributes, nesting: true).tap do |attribute|
                root_exposure.nested_exposures << attribute
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

          def included_exposure
            @included_exposure ||= begin
              ::Grape::Entity::Exposure.new(:included, nesting: true).tap do |inclusion|
                root_exposure.nested_exposures << inclusion
              end
            end
          end
        end

          private

        def self.root(plural, _singular)
          @type_plural = plural
        end

        # expose a field inside of :attributes stanza
        def self.attribute(*args, &block)
          _expose_inside(attributes_exposure, args, &block)
        end

        def self.nest(name, options = {})
          binding.pry
          options[:tracker] ||= Grape::Jsonapi::Exposer::RecurseCounter.new
          _expose_relationships(name, options)
          _expose_included(name, options)
        end

        def self._relationship_options(name, options)
          options.merge(
            as: 'data',
            using: Document.resource_id(name, options.fetch(:using, nil))
          )
        end

        def self._expose_relationships(name, options = {})
          relation = ::Grape::Entity::Exposure
                     .new(name,
                          nesting: true,
                          if: Jsonapi::Exposer.field_exists?(name.to_sym))
          relationships_exposure.nested_exposures << relation
          opts = options.merge(if: Jsonapi::Exposer.field_exists?(name.to_sym))
          _expose_inside(relation, [name, _relationship_options(name, opts)])
        end

        def self._expose_included(name, options = {})
          binding.pry
          opts = options.merge(unless: Jsonapi::Exposer.recursive?(self))
          _expose_inside(included_exposure, [name, opts])
        end

        def self._expose_inside(new_nesting_stack, args, &block)
          # binding.pry
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
