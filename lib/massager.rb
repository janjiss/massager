require "massager/version"
require "dry-types"
require "dry-monads"
require "dry-container"
require "set"

require "massager/attributes/attribute_with_single_key"
require "massager/attributes/attribute_with_multiple_keys"

module Massager
  module ClassMethods
    def attribute(name, *target_keys, **opts, &block)
      case
      when target_keys.count > 1
        register_attribute(
          AttributeWithMultipleKeys.new(name: name, keys: target_keys, opts: opts, block: block)
        )
      when target_keys.count == 1
        register_attribute(
          AttributeWithSingleKey.new(name: name, key: target_keys.first, opts: opts, block: block)
        )
      end
      add_keys_to_schema(opts, target_keys)
      define_setter(name)
      define_getter(name)
    end

    def call(attrs)
      check_schema(attrs)
      instance = new
      _container.each_key.select {|a| a.include?("attributes.")}.each do |k|
        attribute = resolve(k)
        instance.public_send("#{attribute.name}=", attrs) if attribute.match_schema?(attrs)
      end
      instance
    end

    private

    def check_schema(attrs)
      attr_keys = attrs.keys.to_set
      if _container.key?("schema")
        schema = resolve("schema")
        attr_keys = attr_keys.find_all {|a| schema.include?(a)}
        raise ArgumentError, "Missing keys: #{(schema - attr_keys).to_a}" unless schema.subset?(attr_keys.to_set)
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
