module Grape
  module Jsonapi
    module Exceptions
      class UnsupportedMediaTypeError < StandardError
        MESSAGE = 'Unsupported Media Type'

        def initialize(msg=MESSAGE)
          super
        end
      end
    end
  end
end
