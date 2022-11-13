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

  spec.add_development_dependency 'bundler', '>= 2.0.0'
  spec.add_development_dependency 'rake', '>= 10.0.0'
  spec.add_development_dependency 'rspec', '>= 3.0'
  spec.add_development_dependency 'rspec-its', '>=1.0.0'
  spec.add_development_dependency 'rubocop', '>= 1.0.0'
  spec.add_development_dependency 'rubocop-rake', '>= 0.6.0'
  spec.add_development_dependency 'rubocop-rspec', '>= 2.0.0'
  spec.add_development_dependency 'rubygems-tasks', '>= 0.2.0'
  spec.add_development_dependency 'saharspec', '>= 0.0.1'
  spec.add_development_dependency 'simplecov', '>= 0.21.0'
  spec.add_development_dependency 'yard', '>= 0.9.0'

  spec.add_runtime_dependency 'matrix', '>= 0.4.0'
  spec.add_runtime_dependency 'rb_heap', '>= 0.1.0'
end
