module Grape
  module Jsonapi
    module Formatter
      class << self
        def call(object, _env)
          return object if object.is_a?(String)
          return MultiJson.dump(serialize_included(object)) if serializable?(object)
          return object.to_json if object.respond_to?(:to_json)
          MultiJson.dump(object)
        end

        private

        def included
          @included ||= []
        end

        def serializable?(object)
          object.respond_to?(:serializable_hash) || object.is_a?(Array) && object.all? { |o| o.respond_to? :serializable_hash } || object.is_a?(Hash)
        end

        def serialize(object)
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
          return data.map{ |x| collect_included(x) } if data.is_a? Array
          {}.tap do |output|
            data.each_pair do |k, v|
              if k.to_s == 'included'
                included << collect_included(v.values)
              elsif (v.respond_to? :each_pair)
                output[k] = collect_included(v)
              else
                output[k] = v
              end
            end
          end
        end

        def serialize_included(object)
          collect_included(serialize(object))
            .merge(included: included.flatten.uniq)
        end
      end
    end
  end
end
