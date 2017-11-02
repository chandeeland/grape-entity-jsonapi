module Grape
  module Jsonapi
    module Entity
      class Top < Grape::Entity
        expose :errors,
               using: ::Grape::Jsonapi::Entity::Errors,
               if: Jsonapi::Exposer.field_exists?(:errors)

        # meta may display any hash
        expose :meta, if: Jsonapi::Exposer.field_exists?(:meta)

        # A JSON API document MAY include information about its implementation under a top level jsonapi member.
        # If present, the value of the jsonapi member MUST be an object (a jsonapi object).
        # The jsonapi object MAY contain a version member whose value is a string indicating the highest JSON API
        # version supported.
        # This object MAY also contain a meta member, whose value is a meta object that contains non-standard
        # meta-information.
        expose :jsonapi do
          expose :json_api_version, as: :version
        end

        expose :links,
               using: Grape::Jsonapi::Entity::Links,
               if: Jsonapi::Exposer.field_exists?(:links)

        # @TODO implement compound-documents
        # expose :included

        private

        def json_api_version
          ENV['JSON_API_VERSION'] || '1.0'
        end
      end
    end
  end
end
