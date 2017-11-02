module Grape
  module Jsonapi
    module Formatter
      class IncludedRollup
        def initialize(raw_object)
          @raw_object = raw_object
          @included = []
        end

        def rollup
          # binding.pry if raw_object.nil?
          rollup = raw_object
          if raw_object.key? :data
            rollup = rollup.merge(data: data)
            rollup = rollup.merge(included: included)
          end
          rollup
        end

        private

        attr_reader :raw_object, :included

        def data
          # binding.pry if raw_object[:data].nil?
          process_resource_object(raw_object[:data])
        end

        def included
          @included.flatten.compact.uniq
        end

        def process_resource_object(object)
          return object.map { |x| process_resource_object(x) } if object.is_a? Array

          if object.key? :included
            object.delete(:included).values.map do |included_resource|
              # included_resource can be nil as a result of Exposer.recursive?
              @included << process_resource_object(included_resource) unless included_resource.nil?
            end
          end
          object
        end
      end

      class << self
        def call(object, _env)
          return object if object.is_a?(String)

          if object.respond_to?(:serializable_hash)
            formatter = IncludedRollup.new(object.serializable_hash)
            return MultiJson.dump(formatter.rollup)
          end

          return object.to_json if object.respond_to?(:to_json)

          MultiJson.dump(object)
        end
      end
    end
  end
end
