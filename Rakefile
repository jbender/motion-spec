#!/usr/bin/env rake
$LOAD_PATH.unshift('/Library/RubyMotion/lib')
require 'motion/project/template/ios'
require 'bundler/gem_tasks'
Bundler.setup
Bundler.require

require 'motion-spec'

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'MotionSpec'
  app.detect_dependencies = false
end
