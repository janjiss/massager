require "massager/version"
require "dry-types"
require "dry-monads"
require "dry-container"
require "set"

require "massager/attributes/attribute"
require "massager/attributes/enum_attribute"

module Massager
  module ClassMethods
    def attribute(name, *target_keys, **opts, &block)
      register_attribute(
        Attribute.new(name: name, target_keys: target_keys, opts: opts, block: block)
      )
      add_to_schema(opts, target_keys)
      define_setter(name)
      define_getter(name)
    end

    def enum_attribute(name, *target_keys, **opts, &block)
      register_attribute(
        EnumAttribute.new(name: name, target_keys: target_keys, opts: opts, block: block)
      )
      add_to_schema(opts, target_keys)
      define_setter(name)
      define_getter(name)
    end

    def build(attrs)
      check_schema(attrs)
      instance = new
      each_key do |k|
        attribute = resolve(k)
        instance.public_send("#{attribute.name}=", attrs) if attribute.match_schema?(attrs)
      end
      instance
    end

    private

    def check_schema(attrs)
      attr_keys = attrs.keys.to_set
      if key?(:schema)
        schema = resolve(:schema)
        raise ArgumentError, "Missing keys: #{(schema - attr_keys).to_a}" unless schema.superset?(attr_keys) 
      end
    end

    def add_keys_to_schema(opts, target_keys)
      Dry::Monads::Maybe(opts[:strict]).fmap {
        unless key?(:schema)
          register(:schema, Set.new)
        end
        target_keys.each do |k|
          resolve(:schema) << k
        end
      }
    end

    def register_attribute(attribute)
      namespace(:attributes) do
        register(attribute.name, attribute)
      end
    end

    def define_setter(name)
      define_method "#{name}=", Proc.new {|values|
        attribute = self.class.resolve("attributes.#{name}")
        instance_variable_set(:"@#{name}", attribute.call(values))
      }
    end

    def define_getter(name)
      define_method name, Proc.new {
        instance_variable_get(:"@#{name}")
      }
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
    base.extend(Dry::Container::Mixin)
  end
end
