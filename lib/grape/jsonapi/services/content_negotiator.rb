module Grape
  module Jsonapi
    module Services
      class ContentNegotiator
        VALID_MEDIA_TYPE = 'application/vnd+json'.freeze

        def initialize(headers)
          @content_type   = headers['Content-Type']
          @accept_header  = headers['Accept']
        end

        def self.run(*args)
          new(*args).run
        end

        def run
          raise unsupported_media_type_error unless valid?(content_type)
          raise not_acceptable_error unless valid?(accept_header)

          true
        end

        private

        attr_reader :content_type, :accept_header

        def valid?(header)
          VALID_MEDIA_TYPE == header || header.nil?
        end

        def unsupported_media_type_error
          Grape::Jsonapi::Exceptions::UnsupportedMediaTypeError.new
        end

        def not_acceptable_error
          Grape::Jsonapi::Exceptions::NotAcceptableError.new
        end
      end
    end
  end
end
