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

  it "does not conflict with two classes with same attributes" do
    expect {
      First = Class.new do
        include Massager
        column :hello, :world
      end

      Second = Class.new do
        include Massager
        column :hello, :world
      end
    }.not_to raise_error
  end

  it 'works without type conversions' do
    WithoutTypes = Class.new do
      include Massager
      column :foo, "bar"
    end
    testable = WithoutTypes.build({"bar" => "value"})
    expect(testable.foo).to eq("value")
  end

  it "works with type checking" do
    WithTypes = Class.new do
      include Massager
      column :foo, "bar", type: Types::Strict::String
    end
    testable = WithTypes.build({"bar" => "value"})
    expect(testable.foo).to eq("value")
    expect {WithTypes.build({"bar" => 123})}.to raise_error(Dry::Types::ConstraintError)
  end

  it "does the typechecking after the block has been executed" do
    CallableSetter = Class.new do
      include Massager
      column :foo, "bar", type: Types::Strict::String do |v|
        v.to_s
      end
    end
    testable = CallableSetter.build({"bar" => 123})
    expect(testable.foo).to eq("123")
  end
end
