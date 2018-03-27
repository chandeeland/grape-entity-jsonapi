
module Grape
  module Jsonapi
    class Exposer
      def self.field_exists?(field)
        lambda do |instance, _options|
          if instance.is_a? Hash
            (instance.key? field.to_sym) || (instance.key? field)
          else
            (instance.respond_to? field.to_sym) && !instance.send(field.to_sym).nil?
          end
        end
      end

      def self.field(instance, field)
        if instance.is_a? Hash
          return instance[field.to_sym] if instance.key? field.to_sym
          return instance[field] if instance.key? field
        elsif instance.respond_to? field.to_sym
          instance.send(field.to_sym)
        end
      end

      def self.one_level_deep?(field)
        field_exist = field_exists?(field)
        lambda do |instance, options|
          depth = options.opts_hash.dig(:attr_path).count(:included)
          if field_exist.call(instance, options) && depth == 1
            true
          else
            false
          end
        end
      end

      def self.non_empty_array?(field)
        field_exist = field_exists?(field)
        lambda do |instance, options|
          if field_exist.call(instance, options)
            value = field(instance, field)
            if (value.is_a? Array) && (value.count > 0)
              true
            else
              false
            end
          else
            false
          end
        end
      end
    end
  end
end
