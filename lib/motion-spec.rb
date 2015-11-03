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

# Remove the 'spec' file from the core load path so that the copy of "MotionSpec"
# included in RubyMotion is not automatically loaded.
module Motion
  module Project
    class Config
      def spec_core_files
        @spec_core_files ||= begin
          # Core library + core helpers.
          Dir.chdir(File.join(File.dirname(__FILE__), '..')) do
            # NOTE: This line is commented out to avoid loading Bacon. That file
            # not only adds Bacon but monkeypatches things like Kernel.describe
            # that we don't want.
            (#['spec.rb'] +
            Dir.glob(File.join('spec', 'helpers', '*.rb')) +
            Dir.glob(File.join('project', 'template', App.template.to_s, 'spec-helpers', '*.rb'))).
              map { |x| File.expand_path(x) }
          end
        end
      end
    end

    class IOSConfig
      alias_method :old_main_cpp_file_txt, :main_cpp_file_txt

      def main_cpp_file_txt(spec_objs)
        old_main_cpp_file_txt(spec_objs).gsub(/Bacon/, 'MotionSpec')
      end
    end
  end
end
