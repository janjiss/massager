module Massager
  class AttributeWithMultipleKeys
    def initialize(name:, keys:, opts: {}, block: nil)
      raise ArgumentError, "If you pass multiple keys, you have to use modifier block" if block.nil?
      @name, @keys, @opts, @block = name, keys, opts, block
    end

    def call(values)
      values = values.values_at(*keys)
      values = block.call(*values)
      Dry::Monads::Maybe(opts[:type]).fmap {|type| values = type.call(*values)}
      values
    end

    def return_result(values)
      values
    end

    def match_schema?(attrs)
      (attrs.keys & keys).any?
    end

    attr_reader :keys, :block, :opts, :name
  end
end
