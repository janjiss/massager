require "massager/version"
require "dry-types"
require "dry-monads"
require "dry-container"


module Massager
  module ClassMethods
    def column(name, target_key, type: nil, &block)
      set_container
      register_column_info(target_key, name, type, block)
      define_setter(target_key)
      define_getter(target_key)
    end

    def build(attrs)
      instance = self.new
      attrs.each do |k,val|
        container = self.container.resolve(k)
        instance.send("#{container[:name]}=", val)
      end
      instance
    end

    private

    def set_container
      self.define_singleton_method(:container) do
        @container ||= Dry::Container.new
      end
    end

    def define_setter(target_key)
      container = self.container.resolve(target_key)
      define_method "#{container[:name]}=", Proc.new {|val|
        container[:block].fmap {|v| val = v.call(val)}
        container[:type].fmap {|v| val = v[val]}
        instance_variable_set(:"@#{container[:name]}", val)
      }
    end

    def define_getter(target_key)
      container = self.container.resolve(target_key)
      define_method container[:name], Proc.new {
        instance_variable_get(:"@#{container[:name]}")
      }
    end

    def register_column_info(target_key, name, type, block)
      container.register(target_key) do
        {name: name, target_key: target_key, type: Dry::Monads::Maybe(type), block: Dry::Monads::Maybe(block)}
      end
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end
end

