# -*- encoding: utf-8 -*-
require File.expand_path('../lib/jcron/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Johan van den Dorpe"]
  gem.email         = ["johan.vandendorpe@gmail.com"]
  gem.description   = "Jcron"
  gem.summary       = "Jcron - Cron logging and reporting"
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "jcron"
  gem.require_paths = ["lib"]
  gem.version       = Jcron::VERSION
end
