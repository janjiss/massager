module Massager
  class AttributeWithSingleKey
    def initialize(name:, key:, opts: {}, block: nil)
      @name, @key, @opts, @block = name, key, opts, block
    end

    def call(values)
      value = values.fetch(key)
      Dry::Monads::Maybe(block).fmap {|block| value = block.call(value)}
      Dry::Monads::Maybe(opts[:type]).fmap {|type| value = type.call(value)}
      value
    end

    def match_schema?(attrs)
      attrs.keys.include?(key)
    end

    attr_reader :key, :block, :opts, :name
  end
end
