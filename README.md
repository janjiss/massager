# Massager
[![Build Status](https://travis-ci.org/janjiss/massager.svg?branch=master)](https://travis-ci.org/janjiss/massager)
[![Gem Version](https://badge.fury.io/rb/massager.svg)](https://badge.fury.io/rb/massager)
[![Dependency Status](https://gemnasium.com/badges/github.com/janjiss/massager.svg)](https://gemnasium.com/github.com/janjiss/massager)
[![Code Climate](https://codeclimate.com/github/janjiss/massager/badges/gpa.svg)](https://codeclimate.com/github/janjiss/massager)
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
testable = ExampleClass.call({"bar" => "value"})
testable.foo #=> "value"
```
## Strict schema
You can have required keys defined with `strict: true`
```ruby
class ExampleClass
  include Massager
  attribute :foo, "bar", strict: true
end
```
It will raise an error if "bar" is not passed:
```ruby
testable = ExampleClass.call({"bar" => "value"})
testable.foo #=> "value"
testable = ExampleClass.call({"baz" => "value"}) #=> raises ArgumentError
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
testable = ExampleClass.call({"bar" => "value"})
testable.foo #=> "value"
testable = ExampleClass.call({"bar" => 123})  #=> raises Dry::Types::ConstraintError
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
testable = ExampleClass.call({"bar" => "value"})
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
testable = ExampleClass.call({"bar" => "bar", "baz" => "baz"})
testable.foo #=> "bar baz"
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

