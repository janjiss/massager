require "massager/version"
require "dry-types"
require "dry-monads"
require "dry-container"
require "set"

require "massager/errors/constraint_error"
require "massager/attributes/attribute_with_single_key"
require "massager/attributes/attribute_with_multiple_keys"
require "massager/hashify"

module Massager
  module InstanceMethods
    def [](name)
      public_send(name)
    end

    def to_hash
      self.class._container.keys.select {|a| a.include?("attributes.")}.each_with_object({}) do |key, result|
        attribute_name = key.gsub("attributes.", "").to_sym
        result[attribute_name] = Hashify[self[attribute_name]]
      end
    end

    alias_method :to_h, :to_hash
  end

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
      _container.keys.select {|a| a.include?("attributes.")}.each do |k|
        attribute = _container.resolve(k)
        instance.public_send("#{attribute.name}=", attrs) if attribute.match_schema?(attrs)
      end
      instance
    end

    def _container
      @container ||= Dry::Container.new
    end

    private

    def check_schema(attrs)
      attr_keys = attrs.keys.to_set
      if _container.key?("schema")
        schema = _container.resolve("schema")
        attr_keys = attr_keys.find_all {|a| schema.include?(a)}
        raise ArgumentError, "Missing keys: #{(schema - attr_keys).to_a}" unless schema.subset?(attr_keys.to_set)
      end
    end

    def add_keys_to_schema(opts, target_keys)
      Dry::Monads::Maybe(opts[:strict]).fmap {
        unless _container.key?(:schema)
          _container.register(:schema, Set.new)
        end
        target_keys.each do |k|
          _container.resolve(:schema) << k
        end
      }
    end

    def register_attribute(attribute)
      _container.namespace(:attributes) do
        register(attribute.name, attribute)
      end
    end

    def define_setter(name)
      define_method "#{name}=", Proc.new {|values|
        attribute = self.class._container.resolve("attributes.#{name}")
        instance_variable_set(:"@#{name}", attribute.call(values))
      }
    end

    def define_getter(name)
      define_method name, Proc.new {
        instance_variable_get(:"@#{name}")
      }
    end

    def inherited(subclass)
      subclass_container = Dry::Container.new
      _container.keys.each do |k|
        subclass_container.register(k, _container.resolve(k).clone)
      end
      subclass.instance_variable_set(:"@container", subclass_container)
    end
  end


  def self.included(base)
    base.extend(ClassMethods)
    base.include(InstanceMethods)
  end
end
