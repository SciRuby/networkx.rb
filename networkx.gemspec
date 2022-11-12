lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'networkx/version'

NetworkX::DESCRIPTION = <<MSG.freeze
  A Ruby implemenation of the well-known graph library called "networkx".
MSG

Gem::Specification.new do |spec|
  spec.name          = 'networkx'
  spec.version       = NetworkX::VERSION
  spec.authors       = ['Athitya Kumar']
  spec.email         = ['athityakumar@gmail.com']
  spec.summary       = 'A Ruby implemenation of the well-known graph library called networkx.'
  spec.description   = NetworkX::DESCRIPTION
  spec.homepage      = 'https://github.com/athityakumar/networkx.rb'
  spec.license       = 'MIT'
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-its'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rake'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'rubygems-tasks'
  spec.add_development_dependency 'saharspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'yard'

  spec.add_runtime_dependency 'matrix'
  spec.add_runtime_dependency 'rb_heap'
end
