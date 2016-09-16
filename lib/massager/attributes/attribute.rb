module Massager
  class Attribute
    def initialize(name:, target_keys:, opts: {}, block: nil)
      raise ArgumentError, "If you pass multiple keys, you have to use modifier block" if block.nil? && target_keys.count > 1
      @name, @target_keys, @opts, @block = name, target_keys, opts, block
    end

    def call(values)
      begin
        values = values.values_at(*target_keys)
        Dry::Monads::Maybe(block).fmap {|block| values = block.call(*values)}
        Dry::Monads::Maybe(opts[:type]).fmap {|type| values = type.call(*values)}
        return_result(*values)
      rescue ArgumentError
        raise ArgumentError, "The result of modifier block should return single element"
      end
    end

    def return_result(values)
      values
    end

    def match_schema?(attrs)
      (attrs.keys & target_keys).any?
    end

    attr_reader :target_keys, :block, :opts, :name
  end
end
