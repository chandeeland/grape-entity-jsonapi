module Grape
  module Jsonapi
    module Services
      class ContentNegotiator
        attr_reader :accept_header

        def initialize(headers)
          @accept_header = headers['Accept']
        end

        def self.run(*args)
          new(*args).run
        end

        def run

        end

        private

      end
    end
  end
end
