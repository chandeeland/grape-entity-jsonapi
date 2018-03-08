module Grape
  module Jsonapi
    module Exceptions
      class NotAcceptableError < StandardError
        MESSAGE = 'Accept header must be JSON API-compliant'.freeze

        def initialize(msg = MESSAGE)
          super(msg)
        end
      end
    end
  end
end
