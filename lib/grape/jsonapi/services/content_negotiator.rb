module Grape
  module Jsonapi
    module Services
      class ContentNegotiator
        VALID_MEDIA_TYPE = 'application/vnd+json'.freeze

        ERRORS = {
          not_acceptable: {
            status: 406,
            message: 'Not Acceptable'
          },
          unsupported_media: {
            status: 415,
            message: 'Unsupported Media Type'
          }
        }.freeze

        def initialize(headers)
          @content_type   = headers['Content-Type']
          @accept_header  = headers['Accept']
        end

        def self.run(*args)
          new(*args).run
        end

        def run
          return ERRORS[:unsupported_media] unless valid?(content_type)
          return ERRORS[:not_acceptable] unless valid?(accept_header)

          true
        end

        private

        attr_reader :content_type, :accept_header

        def valid?(header)
          VALID_MEDIA_TYPE == header || header.nil?
        end
      end
    end
  end
end
