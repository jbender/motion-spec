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

  def self.add_context(context)
    (@contexts ||= []) << context
  end

  def self.current_context_index
    @current_context_index ||= 0
  end

  def self.current_context
    @contexts[current_context_index]
  end

  def self.run(arg = nil)
    unless respond_to?(:handle_specification_begin)
      extend(Outputs[ENV['output']] || DEFAULT_OUTPUT_MODULE)
    end

    @timer ||= Time.now

    if Platform.android?
      @main_activity ||= arg

      @contexts.each { |context| execute_context(context) }
      return handle_summary
    end

    Counter[:context_depth] += 1
    handle_specification_begin(current_context.name)
    current_context.performSelector('run', withObject: nil, afterDelay: 0)
  end

  def self.execute_context(context)
    unless respond_to?(:handle_specification_begin)
      extend(Outputs[ENV['output']] || DEFAULT_OUTPUT_MODULE)
    end

    Counter[:context_depth] += 1
    handle_specification_begin(context.name)
    context.run
    handle_specification_end
    Counter[:context_depth] -= 1
  end

  # Android-only.
  def self.main_activity
    @main_activity
  end

  def self.context_did_finish(_context)
    return if Platform.android?

    handle_specification_end

    Counter[:context_depth] -= 1

    if (@current_context_index + 1) < @contexts.size
      @current_context_index += 1
      return run
    end

    handle_summary
    exit(Counter.values_at(:failed, :errors).inject(:+))
  end
end
