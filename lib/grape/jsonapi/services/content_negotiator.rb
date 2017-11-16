module Grape
  module Jsonapi
    module Services
      class ContentNegotiator
        VALID_MEDIA_TYPE = "application/vnd+json"

        ERRORS = {
          not_acceptable: {
            status: 406,
            message: "Not Acceptable"
          },
          unsupported_media: {
            status: 415,
            message: "Unsupported Media Type"
          }
        }

        def initialize(api_version, headers)
          @api_version    = api_version
          @accept_version = headers['Accept-Version']
          @content_type   = headers['Content-Type']
          @accept_header  = headers['Accept']
        end

        def self.run(*args)
          new(*args).run
        end

        def run
          return ERRORS[:unsupported_media] unless valid?(content_type)
          return ERRORS[:not_acceptable] unless valid?(accept_header)

          valid_accept_version_header?
        end

        private

        attr_reader :api_version, :accept_version, :content_type, :accept_header

        def valid?(header)
          VALID_MEDIA_TYPE == header || header.nil?
        end

        def valid_accept_version_header?
          api_version == accept_version
        end
      end
    end
  end
end
