# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'activerecord/mysql/awesome/version'

Gem::Specification.new do |spec|
  spec.name          = "activerecord-mysql-awesome"
  spec.version       = ActiveRecord::Mysql::Awesome::VERSION
  spec.authors       = ["Ryuta Kamizono"]
  spec.email         = ["kamipo@gmail.com"]
  spec.summary       = %q{Awesome patches backported for ActiveRecord MySQL adapters}
  spec.description   = %q{Awesome patches backported for ActiveRecord MySQL adapters}
  spec.homepage      = "https://github.com/kamipo/activerecord-mysql-awesome"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_runtime_dependency "activesupport", "~> 4.0"
  spec.add_runtime_dependency "activerecord", "~> 4.0"
  spec.add_runtime_dependency "mysql2", ">= 0.3.18"
end
