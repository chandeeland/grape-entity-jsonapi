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
          object.respond_to?(:serializable_hash) ||
            object.is_a?(Array) &&
              object.all? { |o| o.respond_to? :serializable_hash } ||
            object.is_a?(Hash)
        end

        private

        attr_reader :object, :included

        def serialize_hash
          {}.tap do |h|
            object.each_pair do |k, v|
              h[k] = serialize_included(v)
            end
          end
        end

        # rubocop:disable  Metrics/AbcSize
        def serialize
          return object.serializable_hash if object.respond_to? :serializable_hash
          if object.is_a?(Array) && object.all? { |o| o.respond_to? :serializable_hash }
            return object.map(&:serializable_hash)
          end
          return serialize_hash if object.is_a?(Hash)
          object
        end
        # rubocop:enable  Metrics/AbcSize

        # rubocop:disable  Metrics/MethodLength
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
        # rubocop:enable  Metrics/MethodLength
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
