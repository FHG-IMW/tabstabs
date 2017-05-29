# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tabs_tabs/version'

Gem::Specification.new do |gem|

  gem.name          = "tabstabs"
  gem.version       = TabsTabs::VERSION
  gem.authors       = ["Max Kießling", "Michael Prilop", "JC Grubbs"]
  gem.email         = ['max@kopfueber.org', 'michael.prilop@imw.fraunhofer.de']
  gem.description   = %q{A redis-backed metrics tracker for keeping tabstabs on pretty much anything. Fork of Tabs}
  gem.summary       = %q{A redis-backed metrics tracker for keeping tabstabs on pretty much anything ;)}
  gem.homepage      = "https://github.com/FHG-IMW/tabstabs"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "activesupport", ">= 3.2"
  gem.add_dependency "redis", ">= 3.0.0"

  gem.add_development_dependency "pry"
  gem.add_development_dependency "pry-nav"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "timecop"

end
