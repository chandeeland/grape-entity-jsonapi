module Grape
  module Jsonapi
    module Formatter
      class IncludedRollup
        def initialize(object)
          @object = object
          @included = []
        end

        def serialize_included
          collect_included(serialize)
            .merge(included: included.flatten.uniq)
        end

        def serializable?
          object.respond_to?(:serializable_hash) || object.is_a?(Array) && object.all? { |o| o.respond_to? :serializable_hash } || object.is_a?(Hash)
        end

        private

        attr_reader :object, :included

        def serialize
          if object.respond_to? :serializable_hash
            object.serializable_hash
          elsif object.is_a?(Array) && object.all? { |o| o.respond_to? :serializable_hash }
            object.map(&:serializable_hash)
          elsif object.is_a?(Hash)
            h = {}
            object.each_pair do |k, v|
              h[k] = serialize_included(v)
            end
            h
          else
            object
          end
        end

        def collect_included(data)
          return data.map { |x| collect_included(x) } if data.is_a? Array
          {}.tap do |output|
            data.each_pair do |k, v|
              if k.to_s == 'included'
                included << collect_included(v.values)
              elsif v.respond_to? :each_pair
                output[k] = collect_included(v)
              else
                output[k] = v
              end
            end
          end
        end
      end

      class << self
        def call(object, _env)
          return object if object.is_a?(String)

          formatter = IncludedRollup.new(object)
          return MultiJson.dump(formatter.serialize_included) if formatter.serializable?

          return object.to_json if object.respond_to?(:to_json)
          MultiJson.dump(object)
        end
      end
    end
  end
end
