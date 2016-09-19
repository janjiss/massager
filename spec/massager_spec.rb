require 'spec_helper'
require 'dry-types'
require 'dry-monads'
require 'pry'

module Types
  include Dry::Types.module
end

describe Massager do
  it 'has a version number' do
    expect(Massager::VERSION).not_to be nil
  end

  context "Regular attributes" do
    it "does not conflict with two classes with same attributes" do
      expect {
        First = Class.new do
          include Massager
          attribute :hello, :world
        end

        Second = Class.new do
          include Massager
          attribute :hello, :world
        end
      }.not_to raise_error
    end

    it 'works without type conversions' do
      WithoutTypes = Class.new do
        include Massager
        attribute :foo, "bar"
      end
      testable = WithoutTypes.call({"bar" => "value"})
      expect(testable.foo).to eq("value")
    end

    it "works with type checking" do
      WithTypes = Class.new do
        include Massager
        attribute :foo, "bar", type: Types::Strict::String
      end
      testable = WithTypes.call({"bar" => "value"})
      expect(testable.foo).to eq("value")
      expect {WithTypes.call({"bar" => 123})}.to raise_error(Dry::Types::ConstraintError)
    end

    it "does the typechecking after the block has been executed" do
      CallableSetter = Class.new do
        include Massager
        attribute :foo, "bar", type: Types::Strict::String do |v|
          v.to_s
        end
      end
      testable = CallableSetter.call({"bar" => 123})
      expect(testable.foo).to eq("123")
    end

    it "supports multiple attributes" do
      MultipleArgs = Class.new do
        include Massager
        attribute :foo, "bar","baz", type: Types::Strict::String do |bar, baz|
          bar + baz
        end
      end
      testable = MultipleArgs.call({"bar" => "bar", "baz" => "baz"})
      expect(testable.foo).to eq("barbaz")
    end

    it "raises error if modifier block returns enum attribute" do
      ErrorMultipleArgs = Class.new do
        include Massager
        attribute :foo, "bar","baz", type: Types::Strict::String do |bar, baz|
          [bar, baz]
        end
      end
      expect {
        ErrorMultipleArgs.call({"bar" => "bar", "baz" => "baz"})
        testable.foo
      }.to raise_error(ArgumentError)
    end

    it "raises error if there are multiple attributes and no modifier block" do
      expect {
        ErrorMultipleArgs = Class.new do
          include Massager
          attribute :foo, "bar","baz", type: Types::Strict::String
        end
      }.to raise_error(ArgumentError)
    end

    it "raises error if passed arguments don't comply with strict schema" do
        StrictSchemaError = Class.new do
          include Massager
          attribute :foo, "bar","baz", type: Types::Strict::String, strict: true do |bar, baz|
            bar + baz
          end
          attribute :hello, "world", type: Types::Strict::String, strict: true
        end

      expect {
        StrictSchemaError.call({"bar" => "bar", "foo" => "foo"})
      }.to raise_error(ArgumentError, "Missing keys: [\"baz\", \"world\"]")
    end

  end

  context "Integration" do
    it "works with multiple attributes " do
      MultipleAttributes= Class.new do
        include Massager
        attribute :regular, "regular"
        attribute :with_multiple, "with", "multiple" do |with, multiple|
          with + multiple
        end
      end

      testable = MultipleAttributes.call({"bar" => "bar", "baz" => "baz", "with" => "with", "multiple" => "multiple", "regular" => "regular"})
      expect(testable.regular).to eq("regular")
      expect(testable.with_multiple).to eq("withmultiple")
    end
  end
end
