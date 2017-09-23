# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nickserver/version'

Gem::Specification.new do |gem|
  gem.name          = 'nickserver'
  gem.version       = Nickserver::VERSION
  gem.authors       = ['elijah']
  gem.email         = ['elijah@riseup.net']
  gem.description   = 'Provides a directory service to map uid to public key.'
  gem.summary       = 'Nickserver provides the ability to map a uid (user@domain.org) to a public key. This is the opposite of a key server, whose job it is to map public key to uid. Nickserver is lightweight and asynchronous.'
  gem.homepage      = 'https://leap.se'

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']
  gem.required_ruby_version = '~> 2.1'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'minitest'

  gem.add_dependency 'reel'
  gem.add_dependency 'http'
  # newer versions of nio4r do not work with ruby 2.1
  gem.add_dependency 'nio4r', '~> 1.2'
end
