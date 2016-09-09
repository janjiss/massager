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

## Usage
To start using Massager, just include it in your classes, like so:
```ruby
class ExampleClass
  include Massager
  column :foo, "bar"
end
```
In this scenario, the "bar" key's value will become the result `foo` method
```ruby
testable = ExampleClass.build({"bar" => "value"})
testable.foo #=> "value"
```
You can also pass type checks using dry-types library:
```ruby
class ExampleClass
  include Massager
  column :foo, "bar", type: Types::Strict::String
end
```
It will raise an error if the type is not correct:
```ruby
testable = ExampleClass.build({"bar" => "value"})
testable.foo #=> "value"
testable = ExampleClass.build({"bar" => 123})
testable.foo #=> raises Dry::Types::ConstraintError
```
You can add bit of preprocessing via block (The type check will be preformed afer the block is executed):
```ruby
class ExampleClass
  include Massager
  column :foo, "bar", type: Types::Strict::String do |v|
    v.upcase
  end
end
```
And it will have following result
```ruby
testable = ExampleClass.build({"bar" => "value"})
testable.foo #=> "VALUE"
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

