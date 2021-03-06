# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'yodeler/version'

Gem::Specification.new do |spec|
  spec.name          = 'yodeler'
  spec.version       = Yodeler::VERSION
  spec.authors       = ["Cory O'Daniel"]
  spec.email         = ['github@coryodaniel.com']
  spec.description   = 'A generic instrumentation library thats supports reporting to multiple endpoints via pluggable backend adapters.'
  spec.summary       = "A generic instrumentation library thats supports reporting to multiple endpoints via pluggable backend adapters. Spoutin' off noise to whoever is listening."
  spec.homepage      = 'http://github.com/coryodaniel/yodeler'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'http'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'rspec-mocks'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'codeclimate-test-reporter'
end
