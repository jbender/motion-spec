# encoding: utf-8

require 'motion-require'

Motion::Require.all(Dir.glob('motion-spec/**/*.rb'))

# Do not log all exceptions when running the specs.
Exception.log_exceptions = false

# FIXME : Need better detection for iPhone Simulator
if defined?(UIDevice)
  && UIDevice.respond_to?("currentDevice")
  && !UIDevice.currentDevice.name =~ /(iPhone|iPad) Simulator/

  module Kernel
    def puts(*args)
      NSLog(args.join("\n"))
    end

    def print(*args)
      puts *args # TODO
    end
  end
end
