module Massager
  class EnumAttribute
    def initialize(name:, target_keys:, opts: {}, block:)
      @name, @target_keys, @opts, @block = name, target_keys, opts, block
    end

    def call(values)
      values = values.values_at(*target_keys)
      Dry::Monads::Maybe(block).fmap {|block| values = block.call(values)}
      Dry::Monads::Maybe(opts[:type]).fmap {|type| values = type.call(values)}
      raise ArgumentError, "The result of modifier block is not an enum" unless values.respond_to? :each
      values
    end

    def match_schema?(attrs)
      (attrs.keys & target_keys).any?
    end

    attr_reader :target_keys, :block, :opts, :name
  end
end
