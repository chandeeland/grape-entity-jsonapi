module Grape
  module Jsonapi
    module Formatter
      class IncludedRollup
        def initialize(raw_object)
          @raw_object = raw_object
          @included = []
        end

        def serialize_included
          collect_included(object)
            .merge(included: included.flatten.uniq)
        end

        def serializable?
          object.respond_to?(:serializable_hash) ||
            object.is_a?(Array) &&
              object.all? { |o| o.respond_to? :serializable_hash } ||
            object.is_a?(Hash)
        end

        private

        attr_reader :raw_object, :included

        def object
          serialize(raw_object)
        end

        # rubocop:disable  Metrics/AbcSize
        def serialize(data)
          if data.respond_to? :serializable_hash
            data.serializable_hash
          elsif data.is_a?(Array) && data.all? { |o| o.respond_to? :serializable_hash }
            data.map(&:serializable_hash)
          elsif data.is_a?(Hash)
            serialize_hash(data)
          else
            data
          end
        end
        # rubocop:enable  Metrics/AbcSize

        def serialize_hash(hash_object)
          {}.tap do |h|
            hash_object.each_pair do |k, v|
              h[k] = serialize(v)
            end
          end
        end

        # rubocop:disable  Metrics/MethodLength
        def collect_included(data)
          return data.map { |x| collect_included(x) }.compact if data.is_a? Array

          {}.tap do |output|
            unless data.nil?
              data.each_pair do |k, v|
                if k.to_s == 'included'
                  @included << collect_included(v.values)
                elsif v.respond_to? :each_pair
                  output[k] = collect_included(v)
                else
                  output[k] = v
                end
              end
            end
          end
        end
        # rubocop:enable  Metrics/MethodLength
      end

      class << self
        def call(object, _env)
          return object if object.is_a?(String)
          formatter = IncludedRollup.new(::Grape::Json.dump(object))
          return MultiJson.dump(formatter.serialize_included) if formatter.serializable?

          return object.to_json if object.respond_to?(:to_json)
          MultiJson.dump(object)
        end
      end
    end
  end
end
