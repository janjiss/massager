require "massager/version"
require "dry-types"
require "dry-monads"
require "dry-container"

require "massager/attributes/attribute"
require "massager/attributes/enum_attribute"

module Massager
  module ClassMethods
    def attribute(name, *target_keys, **opts, &block)
      set_container
      register_attribute(
        Attribute.new(name: name, target_keys: target_keys, opts: opts, block: block)
      )
      define_setter(name)
      define_getter(name)
    end

    def enum_attribute(name, *target_keys, **opts, &block)
      set_container
      register_attribute(
        EnumAttribute.new(name: name, target_keys: target_keys, opts: opts, block: block)
      )
      define_setter(name)
      define_getter(name)
    end

    def build(attrs)
      instance = new
      container.each_key do |k|
        attribute = container.resolve(k)
        instance.public_send("#{k}=", attrs) if attribute.match_schema?(attrs)
      end
      instance
    end

    private

    def register_attribute(attribute)
      container.register(attribute.name) {attribute}
    end

    def define_setter(name)
      define_method "#{name}=", Proc.new {|values|
        attribute = self.class.container.resolve(name)
        instance_variable_set(:"@#{name}", attribute.call(values))
      }
    end

    def define_getter(name)
      define_method name, Proc.new {
        instance_variable_get(:"@#{name}")
      }
    end

    def set_container
      self.define_singleton_method(:container) do
        @container ||= Dry::Container.new
      end
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end
end
