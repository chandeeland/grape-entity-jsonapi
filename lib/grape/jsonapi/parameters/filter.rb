module Grape
  module Jsonapi
    module Parameters
      # rubocop:disable Metrics/ClassLength
      class Filter
        class FilterBase
          OP_EQ = 'eq'.freeze
          OP_NE = 'ne'.freeze
          OP_GT = 'gt'.freeze
          OP_LT = 'lt'.freeze
          OP_GTE = 'gte'.freeze
          OP_LTE = 'lte'.freeze
          OP_IN = 'in'.freeze

          # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
          def self.parse(param)
            filter = JSON.parse(param, symbolize_names: true)
            valid_and_default_keys = valid_keys + (try(:default_params) && default_params.keys || [])
            good_keys = (valid_and_default_keys & filter.keys) || []
            unless good_keys.count == filter.keys.count
              error = "Invalid filter keys, #{(filter.keys - valid_and_default_keys)}"
              raise Grape::Jsonapi::Exceptions::FilterError.new(error)
            end
            new(filter)
          end
          # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

          def self.default(default_params)
            define_singleton_method(:default_params) do
              default_params
            end

            self
          end

          attr_reader :query_params

          def initialize(filter = {})
            @query_params = (self.class.try(:default_params) || {})
                            .merge(filter).each_with_object({}) do |(k, v), result|

              result[k] = parse_value(v)
            end
            validate!
          end

          def allowed_operations
            @allowed_operations ||= [OP_EQ, OP_GT, OP_GTE, OP_LT, OP_LTE, OP_NE, OP_IN]
          end

          def scalar?(value)
            [Integer, Float, String].map { |type| value.is_a? type }.any?
          end

          def parse_value(value)
            [].tap do |result|
              if value.is_a? Array
                result << [OP_IN, value]
              elsif scalar?(value)
                result << [OP_EQ, value]
              elsif value.is_a? Hash
                value.each_pair { |value_key, scalar_value| result << [value_key.downcase, scalar_value] }
              end
            end
          end

          def filters
            query_params.each_pair do |key, qfilters|
              unless (qfilters.is_a? Array) && !qfilters.empty?
                raise Grape::Jsonapi::Exceptions::FilterError.new("Invalid type for #{key}")
              end
              qfilters.each do |(op, value)|
                yield(key, op, value)
              end
            end
          end

          def validate_op_in(key, value)
            [].tap do |errors|
              if value.is_a? Array
                value.each do |v|
                  errors << "#{key} has invalid array member, #{v}" unless scalar?(v)
                end
              else
                errors << "#{key} '#{OP_IN}' operation requires an array"
              end
            end
          end

          # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
          def validate!
            errors = []
            filters do |key, op, value|
              if !(allowed_operations.include? op.to_s)
                errors << "#{key}: Invalid operation '#{op}', should be one of #{allowed_operations.join(', ')}"
              elsif op.to_s == OP_IN
                errors += validate_op_in(key, value)
              else
                errors << "Expected scalar type for #{key} using #{op}" unless scalar?(value)
              end
            end
            raise Grape::Jsonapi::Exceptions::FilterError.new(JSON.unparse(errors)) if errors.count > 0
          end
          # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

          def query_for(model)
            return query_for_sql(model) if model.is_a? ActiveRecord::Base
            return query_for_mongo(model) if model.is_a? Mongoid::Document
          end

          # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
          def query_for_sql(model)
            result = nil
            filters do |key, op, value|
              query = result || model
              result = case op.to_s
                       when OP_EQ
                         query.where(key => value)
                       when OP_IN
                         query.where(key => value)
                       when OP_NE
                         query.where_not(key => value)
                       when OP_GT
                         query.where("#{key} > ?", value)
                       when OP_LT
                         query.where("#{key} < ?", value)
                       when OP_GTE
                         query.where("#{key} >= ?", value)
                       when OP_LTE
                         query.where("#{key} <= ?", value)
                       end
            end
            result
          end
          # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity

          # rubocop:disable Metrics/MethodLength
          def query_for_mongo(model)
            result = nil
            filters do |key, op, value|
              query = result || model

              result = case op.to_s
                       when OP_EQ
                         query.where(key => value)
                       when OP_IN
                         query.in(key => value)
                       else
                         query.send(op, key => value)
                       end
            end

            result
          end
          # rubocop:enable Metrics/MethodLength
        end

        # Filter formats:
        #   filter accepts a Hash
        #   key is assumed to be the search field.
        #
        #   when value is scalar type, operation 'equals(==)' is implied.
        #     { foo: 'scalar', bar: 123 } => where(foo: 'scalar', bar: 123)
        #   if value is an array, 'IN' operation is applied
        #     { foo: [1,2,3] } => where(:foo.in([1,2,3]))
        #   if value is a Hash, there must be one entry,
        #   of which the value_key is the operation, and the value must be scalar
        #     { foo: {'<': 100 } } => where(foo < 100)
        #   valid operations include <, <=, >, >=, ==
        #
        def self.allow(valid_keys)
          Class.new(FilterBase).tap do |klass|
            klass.define_singleton_method(:valid_keys) do
              valid_keys.map(&:to_sym)
            end
          end
        end
      end
      # rubocop:enable Metrics/ClassLength
    end
  end
end
