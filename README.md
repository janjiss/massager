# Massager

Have you ever felt a need to massage your data just a little bit before working with it? This is what Massager was built for.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'massager'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install massager

## Simplest usecase
To start using Massager, just include it in your classes, like so:
```ruby
class ExampleClass
  include Massager
  attribute :foo, "bar"
end
```
In this scenario, the "bar" key's value will become the result `foo` method
```ruby
testable = ExampleClass.build({"bar" => "value"})
testable.foo #=> "value"
```

## Type checking
You can also pass type checks using dry-types library:
```ruby
class ExampleClass
  include Massager
  attribute :foo, "bar", type: Types::Strict::String
end
```
It will raise an error if the type is not correct:
```ruby
testable = ExampleClass.build({"bar" => "value"})
testable.foo #=> "value"
testable = ExampleClass.build({"bar" => 123})
testable.foo #=> raises Dry::Types::ConstraintError
```
If you want to define your own types, check the Dry Types library. Type needs to respond to `call` method, so 
you can define your own

## Preprocessing the value via block

You can add bit of preprocessing via block (The type check will be preformed afer the block is executed):
```ruby
class ExampleClass
  include Massager
  attribute :foo, "bar", type: Types::Strict::String do |v|
    v.upcase
  end
end
```
And it will have following result
```ruby
testable = ExampleClass.build({"bar" => "value"})
testable.foo #=> "VALUE"
```

## Combining multiple keys

```ruby
class ExampleClass
  include Massager
  attribute :foo, "bar", "baz", type: Types::Strict::String do |bar, baz|
    "#{bar} #{baz}"
  end
end
```
Note that if you pass multiple keys, the modifier block is mandatory

```ruby
testable = ExampleClass.build({"bar" => "bar", "baz" => "baz"})
testable.foo #=> "bar baz"
```

## Enum attributes
If you want to have enum as a result, you will need to use `enum_attribute`
```ruby
class ExampleClass
  include Massager
  enum_attribute :foo, "bar", "baz"
end
```
```ruby
testable = ExampleClass.build({"bar" => "bar", "baz" => "baz"})
testable.foo #=> ["bar", "baz"]
```

## Enum attribute with modifier
You can apply modifications to the collection
```ruby
class ExampleClass
  include Massager
  enum_attribute :foo, "bar", "baz" do |values| 
    values.reverse
  end
end
```
```ruby
testable = ExampleClass.build({"bar" => "bar", "baz" => "baz"})
testable.foo #=> ["baz", "bar"]
```

## Enum attribute with type check
You can provide type checks as well
```ruby
class ExampleClass
  include Massager
  enum_attribute :foo, "bar", "baz", type: Types::Strict::Array.member(Types::Strict::String)
end
```
```ruby
testable = ExampleClass.build({"bar" => "bar", "baz" => "baz"})
testable.foo #=> ["bar", "baz"]

testable = ExampleClass.build({"bar" => 123, "baz" => "baz"}) # Will raise Dry::Types::ConstraintError
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

