# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'modular_engine/version'

Gem::Specification.new do |spec|
  spec.name          = "modular_engine"
  spec.version       = ModularEngine::VERSION
  spec.authors       = ["Thibault"]
  spec.email         = ["thibault@appyhotel.com"]
  spec.summary       = 'Generate modular Rails engines.'
  spec.description   = 'This gem will generate modular engines as shown in the book Modular Rails at http://modularity.samurails.com.'
  spec.homepage      = "https://github.com/T-Dnzt/Modular-Engine"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
