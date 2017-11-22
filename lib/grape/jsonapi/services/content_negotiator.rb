module Grape
  module Jsonapi
    module Services
      class ContentNegotiator
        VALID_MEDIA_TYPE = 'application/vnd.api+json'.freeze

        def initialize(accept_header:, content_type:)
          @accept_header  = accept_header
          @content_type   = content_type
        end

        def self.run(*args)
          new(*args).run
        end

        def run
          raise unsupported_media_type_error  unless valid?(content_type)
          raise not_acceptable_error          unless valid_accept_header?

          true
        end

        private

        attr_reader :accept_header, :content_type

        def valid?(header)
          VALID_MEDIA_TYPE == header
        end

        def valid_accept_header?
          valid?(accept_header) || accept_header.nil?
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
