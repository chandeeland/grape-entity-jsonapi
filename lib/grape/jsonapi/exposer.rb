
module Grape
  module Jsonapi
    class Exposer

      class RecurseCounter
        def self.instance
          @instance ||= new
        end

        def self.found?(obj)
          instance.found?(obj)
        end

        def found?(obj)
          return nil if obj.nil?
          return nil unless obj.respond_to? :id
          key = "#{obj.class.name}#{obj.id}"
          answer = @counter.key? key
          @counter[key] = true
          answer
        end

        private

        attr_reader :counter

        def initialize
          @counter = {}
        end

      end

      def self.non_recursive?(field)
        lambda do |instance, _options|
          if instance.is_a? Hash
            RecurseCounter.found?(instance.key? field.to_sym) || (instance.key? field.to_s)
          elsif instance.respond_to? field.to_sym
            RecurseCounter.found?(instance.send(field.to_sym))
          end
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
