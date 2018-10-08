lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gosling/version'

Gem::Specification.new do |spec|
  spec.name        = 'gosling'
  spec.version     = Gosling::VERSION
  spec.date        = '2018-10-07'
  spec.summary     = "Ruby 2D app creation"
  spec.description = "A lightweight library for creating 2D apps in Ruby."
  spec.authors     = ['Ben Amos']
  spec.email       = ['flashguardian13@gmail.com']
  spec.homepage    = 'https://github.com/flashguardian13/gosling'
  spec.license     = 'GNU GENERAL PUBLIC LICENSE'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'gosu', '~> 0.14'

  spec.add_development_dependency 'rspec'
end
