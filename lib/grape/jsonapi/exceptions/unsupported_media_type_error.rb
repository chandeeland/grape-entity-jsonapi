module Grape
  module Jsonapi
    module Exceptions
      class UnsupportedMediaTypeError < StandardError
        MESSAGE = 'Content-Type must be JSON API-compliant'.freeze

        def initialize(msg = MESSAGE)
          super(msg)
        end
      end
    end
  end
end
