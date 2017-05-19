module GrapeEntityJsonapi
  class Errors < Grape::Entity
    # a unique identifier for this particular occurrence of the problem
    expose :id, if: id

    expose :links, if: links.count, type: Array do
      # a link that leads to further details about this particular occurrence of the problem.
      expose :about
    end

    # the HTTP status code applicable to this problem, expressed as a string value.
    expose :status, if: status

    # an application-specific error code, expressed as a string value.
    expose :code, if: code

    # a short, human-readable summary of the problem that SHOULD NOT change
    # from occurrence to occurrence of the problem, except for purposes of localization.
    expose :title, if: title

    # a human-readable explanation specific to this occurrence of the problem.
    # Like title, this field’s value can be localized.
    expose :detail, if: detail

    # an object containing references to the source of the error,
    expose :source, if: source, type: Hash do
      # optionally including any of the following members:

      # a JSON Pointer [RFC6901] to the associated entity in the request document
      # [e.g. "/data" for a primary data object, or "/data/attributes/title" for a specific attribute].
      expose :pointer, if: pointer

      # a string indicating which URI query parameter caused the error.
      expose :parameter, if: parameter
    end

    private

    def status
      object.status.to_i || 400
    end

    def title
      object.title || 'Unknown Error'
    end

    def detail
      object.title || %(
      The server cannot or will not process the request due to something that is
      perceived to be a client error (e.g., malformed request syntax, invalid
      request message framing, or deceptive request routing).
      )
    end
  end
end
