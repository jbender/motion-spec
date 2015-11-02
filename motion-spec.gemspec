# encoding: utf-8
require File.expand_path('../lib/motion-spec/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name    = 'motion-spec'
  spec.version = Motion::Spec::VERSION
  spec.authors = ['Jonathan Bender']
  spec.email   = ['jlbender@gmail.com']

  spec.summary     = %q{RubyMotion derivative of Bacon, which is a derivative of RSpec}
  spec.description = %q{RubyMotion derivative of Bacon, which is a derivative of RSpec}
  spec.homepage    = 'https://github.com/jbender/motion-spec'
  spec.license     = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']

  spec.add_dependency 'motion-require', '>= 0.0.6'

  spec.add_development_dependency 'rake', '~> 10.0'
end
