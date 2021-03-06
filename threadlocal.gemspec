# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "threadlocal"
  spec.version       = "0.0.1"
  spec.authors       = ["Martin Schürrer"]
  spec.email         = ["martin@schuerrer.org"]
  spec.summary       = %q{Java/Python-like OO thread local variables}
  spec.description   = %q{OO alternative to Thread#thread_variable_get/set}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
