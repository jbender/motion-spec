# -*- encoding : utf-8 -*-
unless defined?(Motion::Project::Config)
  raise "The MotionSpec gem must be required within a RubyMotion project Rakefile."
end

require 'motion-require'

# Proper load order of all the classes/modules
###

# Let's start off with what version we're running
Motion::Require.all('lib/motion-spec/version.rb')

# Load the output before the core so the core knows how to print
Motion::Require.all(Dir.glob('lib/motion-spec/output/*.rb'))

# All the other core modules in the proper order
Motion::Require.all([
  'lib/motion-spec/core.rb',
  'lib/motion-spec/error.rb',
  'lib/motion-spec/specification.rb',
  'lib/motion-spec/platform.rb',
  'lib/motion-spec/context.rb',
  'lib/motion-spec/should.rb'
])

# Monkeypatch core objects to respond to test methods
Motion::Require.all(Dir.glob('lib/motion-spec/extensions/*.rb'))

# Clobber RubyMotion's built-in specs
Motion::Require.all('lib/motion-spec/clobber_bacon.rb')

# Do not log all exceptions when running the specs.
Exception.log_exceptions = false if Exception.respond_to? :log_exceptions

# FIXME : Need better detection for iPhone Simulator
if defined?(UIDevice) &&
  UIDevice.respond_to?("currentDevice") &&
  !UIDevice.currentDevice.name =~ /(iPhone|iPad) Simulator/

  module Kernel
    def puts(*args)
      NSLog(args.join("\n"))
    end

    def print(*args)
      puts *args # TODO
    end
  end
end
