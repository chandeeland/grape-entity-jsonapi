module Grape
  module Jsonapi
    module Parameters
      class Filter
        class FilterBase
          attr_reader :value
          def initialize(filter)
            @value = filter
          end

          def self.parse(param)
            filter = JSON.parse(param, symbolize_names: true)
            errors = []
            filter.each_pair do |key, value|
              errors << "Invalid key: #{key}" unless valid_keys.include? key
              errors += validate_values(key, value)
            end
            raise Grape::Jsonapi::Exceptions::FilterError.new(JSON.unparse(errors)) if errors.count > 0
            new(filter)
          end

          def self.validate_values(key, value)
            errors = []
            if value.is_a? Array
              value.each do |v|
                errors << "Invalid type in array for #{key}" unless scalar?(v)
              end
            else
              errors << "Invalid type for #{key}" unless scalar?(value)
            end
            errors
          end

          def self.scalar?(value)
            (value.is_a? Numeric) || (value.is_a? String)
          end

          def query_for(model)
            value.keys.reduce(model) do |query, key|
              data = value[key]
              if data.is_a? Array
                query.in(key => data)
              else
                query.where(key => data)
              end
              query
            end
          end
        end

        def self.allow(valid_keys)
          Class.new(FilterBase).tap do |klass|
            klass.define_singleton_method(:valid_keys) do
              valid_keys.map(&:to_sym)
            end
          end
        end
      end
    end
  end
end
