# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'massager/version'

Gem::Specification.new do |spec|
  spec.name          = "massager"
  spec.version       = Massager::VERSION
  spec.authors       = ["Janis Miezitis"]
  spec.email         = ["janjiss@gmail.com"]

  spec.summary       = %q{Massager is a gem that helps to transform the data}
  spec.description   = %q{Massager is built for CSV row parsing and transforming, but there is no reason not to use it on plain hashes}
  spec.homepage      = "http://github.com/janjiss/massager"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "dry-types", "~> 0.8"

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry", "~> 0.10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
