# coding: utf-8
# lib = File.expand_path('../lib', __FILE__)
# # $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
# require 'proteste_generate_application/version'

require File.expand_path('../lib/proteste_generate_application/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = "proteste_generate_application"
  spec.version       = ProtesteGenerateApplication::VERSION
  spec.authors       = ["rodrigo toledo"]
  spec.email         = ["rtoledo@proteste.org.br"]
  spec.description   = %q{Generate applications with default layout, authentication and authorization}
  spec.summary       = %q{Generate applications with default layout, authentication and authorization}
  spec.homepage      = ""

  spec.files         = Dir["lib/**/*"]
  spec.executables   = spec.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_dependency('activemodel')
  spec.add_dependency('actionpack')
  spec.add_dependency('httparty')
  spec.add_runtime_dependency('rubyzip', '~> 0.9.9')
end
