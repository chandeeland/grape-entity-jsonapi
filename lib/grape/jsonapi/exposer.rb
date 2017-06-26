
module Grape
  module Jsonapi
    class Exposer

      def self.field_exists?(field)
        lambda do |instance, _options|
          if instance.is_a? Hash
            (instance.key? field.to_sym) || (instance.key? field)
          else
            (instance.respond_to? field.to_sym) && !(instance.send(field.to_sym).nil?)
          end
        end
      end

      def self.field(instance, field)
        if instance.is_a? Hash
          return instance[field.to_sym] if instance.key? field.to_sym
          return instance[field] if instance.key? field
        else
          return instance.send(field.to_sym) if instance.respond_to? field.to_sym
        end
      end

    end
  end
end
