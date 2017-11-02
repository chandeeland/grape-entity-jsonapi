
module Grape
  module Jsonapi
    class Exposer

      class RecurseCounter
        def initialize
          @counter = {}
        end

        def found?(obj)
          return false if obj.nil?
          return false unless obj.respond_to? :id

          key = "#{obj.class.name}#{obj.id}"
          answer = @counter.key? key
          @counter[key] = true
          answer
        end

        private

        attr_reader :counter
      end

      def self.recursive?(field)
        lambda do |instance, options|
          if instance.is_a? Hash
            value = (instance.key? field.to_sym) || (instance.key? field.to_s)
          elsif instance.respond_to? field.to_sym
            value = instance.send(field.to_sym)
          end
          value ? options[:tracker].found?(value) : false
        end
      end

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

      def self.non_empty_array?(field)
        field_exist = field_exists?(field)
        lambda do |instance, options|
          if field_exist.call(instance, options)
            value = field(instance, field)
            return true if (value.is_a? Array) && (value.count > 0)
          end
          false
        end
      end
    end
  end
end
