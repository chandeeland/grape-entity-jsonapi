module GrapeEntityJsonapi
  class Top < Grape::Entity
    expose :data,
           using: ::GrapeEntityJsonapi::Resource,
           unless: ->(_intance, _options) { instance.errors.present? }

    expose :errors,
           using: ::GrapeEntityJsonapi::Errors,
           if: ->(_intance, _options) { instance.errors.present? }

    # meta may display any hash
    expose :meta, if: ->(instance, _options) { instance.meta.present? }

    # A JSON API document MAY include information about its implementation under a top level jsonapi member.
    # If present, the value of the jsonapi member MUST be an object (a jsonapi object).
    # The jsonapi object MAY contain a version member whose value is a string indicating the highest JSON API
    # version supported.
    # This object MAY also contain a meta member, whose value is a meta object that contains non-standard
    # meta-information.
    expose :jsonapi do
      expose :json_api_version, as: :version
    end

    expose :links, using: GrapeEntityJsonapi::Links

    # @TODO implement compound-documents
    # expose :included

    private

    def json_api_version
      ENV['JSOIN_API_VERSION'] || '1.0'
    end
  end
end
