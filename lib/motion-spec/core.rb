# -*- encoding : utf-8 -*-
# MotionSpec is built off of MacBacon, which is derived from Bacon, which is a
# micro-port of Rspec. See the LICENSE for core contributors and copyright years

module MotionSpec
  DEFAULT_OUTPUT_MODULE = SpecDoxOutput

  Counter = Hash.new(0)
  ErrorLog = ''
  Shared = Hash.new do |_, name|
    fail NameError, "no such context: #{name.inspect}"
  end

  RestrictName    = //  unless defined? RestrictName
  RestrictContext = //  unless defined? RestrictContext

  Backtraces = true unless defined? Backtraces

  Outputs = {
    'spec_dox' => SpecDoxOutput,
    'fast' => FastOutput,
    'test_unit' => TestUnitOutput,
    'tap' => TapOutput,
    'knock' => KnockOutput,
    'rubymine' => RubyMineOutput,
    'colorized' => ColorizedOutput
  }

  class << self
    def add_context(context)
      (@contexts ||= []) << context
    end

    def current_context_index
      @current_context_index ||= 0
    end

    def current_context
      @contexts[current_context_index]
    end

    def run(arg = nil)
      set_default_output

      @timer ||= Time.now

      Counter[:context_depth] += 1
      Platform.android? ? run_android_specs : run_cocoa_specs
    end

    # Android-only.
    def main_activity
      @main_activity
    end

    def context_did_finish(context)
      return if Platform.android?

      Counter[:context_depth] -= 1

      handle_specification_end

      if (@current_context_index + 1) < @contexts.size
        @current_context_index += 1
        return run
      end

      handle_summary

      exit(Counter.values_at(:failed, :errors).inject(:+))
    end

    private

    def execute_context(context)
      set_default_output

      handle_specification_begin(context.name)
      context.run
      handle_specification_end
    end

    def run_android_specs
      @main_activity ||= arg
      @contexts.each { |context| execute_context(context) }
      handle_summary
    end

    def run_cocoa_specs
      handle_specification_begin(current_context.name)
      current_context.performSelector('run', withObject: nil, afterDelay: 0)
    end

    def set_default_output
      return if respond_to?(:handle_specification_begin)

      extend(Outputs[ENV['output']] || DEFAULT_OUTPUT_MODULE)
    end
  end
end
