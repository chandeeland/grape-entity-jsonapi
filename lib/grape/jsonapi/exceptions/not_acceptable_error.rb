module Grape
  module Jsonapi
    module Exceptions
      class NotAcceptableError < StandardError
        MESSAGE = 'Not Acceptable'.freeze

        def initialize(msg = MESSAGE)
          super
        end
      end
    end
  end
end
