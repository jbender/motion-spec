# encoding: utf-8
#
# Bacon -- small RSpec clone.
#
# "Truth will sooner come out from error than from confusion." ---Francis Bacon
#
# Copyright (C) 2011 Eloy Durán eloy.de.enige@gmail.com
# Copyright (C) 2007 - 2011 Christian Neukirchen <purl.org/net/chneukirchen>
#
# Bacon is freely distributable under the terms of an MIT-style license.
# See COPYING or http://www.opensource.org/licenses/mit-license.php.

module Bacon
  DEFAULT_OUTPUT_MODULE = MotionSpec::SpecDoxOutput

  Counter = Hash.new(0)
  ErrorLog = ""
  Shared = Hash.new { |_, name|
    raise NameError, "no such context: #{name.inspect}"
  }

  RestrictName    = //  unless defined? RestrictName
  RestrictContext = //  unless defined? RestrictContext

  Backtraces = true  unless defined? Backtraces

  Outputs = {
    'spec_dox' => MotionSpec::SpecDoxOutput,
    'fast' => MotionSpec::FastOutput,
    'test_unit' => MotionSpec::TestUnitOutput,
    'tap' => MotionSpec::TapOutput,
    'knock' => MotionSpec::KnockOutput,
    'rubymine' => MotionSpec::RubyMineOutput,
    'colorized' => MotionSpec::ColorizedOutput,
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

  def self.run(arg=nil)
    unless respond_to?(:handle_specification_begin)
      extend(Outputs[ENV['output']] || DEFAULT_OUTPUT_MODULE)
    end

    @timer ||= Time.now
    unless Platform.android?
      Counter[:context_depth] += 1
      handle_specification_begin(current_context.name)
      current_context.performSelector("run", withObject:nil, afterDelay:0)
    else
      @main_activity ||= arg

      @contexts.each { |context| execute_context(context) }
      handle_summary
    end
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

  def self.context_did_finish(context)
    unless Platform.android?
      handle_specification_end
      Counter[:context_depth] -= 1
      if (@current_context_index + 1) < @contexts.size
        @current_context_index += 1
        run
      else
        # DONE
        handle_summary
        unless Platform.android?
          exit(Counter.values_at(:failed, :errors).inject(:+))
        else
          # In Android there is no need to exit as we terminate the activity right after Bacon.
        end
      end
    end
  end
end
