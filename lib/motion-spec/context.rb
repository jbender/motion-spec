# -*- encoding : utf-8 -*-
module MotionSpec
  class Context
    attr_reader :name, :block

    def initialize(name, before = nil, after = nil, &block)
      @name = name
      @before, @after = (before ? before.dup : []), (after ? after.dup : [])
      @block = block
      @specifications = []
      @current_specification_index = 0

      MotionSpec.add_context(self)

      instance_eval(&block)
    end

    def run
      # TODO
      #return  unless name =~ RestrictContext

      if Platform.android?
        @specifications.each { |spec| spec.run }
      else
        spec = current_specification
        return spec.performSelector("run", withObject:nil, afterDelay:0) if spec
      end

      MotionSpec.context_did_finish(self)
    end

    def current_specification
      @specifications[@current_specification_index]
    end

    def specification_did_finish(spec)
      return if Platform.android?

      if (@current_specification_index + 1) < @specifications.size
        @current_specification_index += 1
        return run
      end

      MotionSpec.context_did_finish(self)
    end

    def before(&block)
      @before << block
    end

    def after(&block)
      @after << block
    end

    def behaves_like(*names)
      names.each { |name| instance_eval(&Shared[name]) }
    end

    def it(description, &block)
      return  unless description =~ RestrictName
      block ||= proc { should.flunk "not implemented" }
      Counter[:specifications] += 1
      @specifications << Specification.new(self, description, block, @before, @after)
    end

    def should(*args, &block)
      return it('should ' + args.first, &block) if Counter[:depth] == 0

      super(*args, &block)
    end

    def describe(*args, &block)
      p 'describing via Context'
      p args.join(' ')
      context = MotionSpec::Context.new(args.join(' '), @before, @after, &block)

      p context
      p Platform.android?

      # FIXME: fix RM-879 and RM-806
      build_ios_parent_context(context) unless Platform.android?

      context
    end
    alias_method :context, :describe

    def wait(seconds = nil, &block)
      return current_specification.schedule_block(seconds, &block) if seconds

      current_specification.postpone_block(&block)
    end

    def wait_max(timeout, &block)
      current_specification.postpone_block(timeout, &block)
    end

    def wait_for_change(object_to_observe, key_path, timeout = 1, &block)
      current_specification.postpone_block_until_change(
        object_to_observe,
        key_path,
        timeout,
        &block
      )
    end

    def resume
      current_specification.resume
    end

    def raise?(*args, &block)
      block.raise?(*args)
    end

    def throw?(*args, &block)
      block.throw?(*args)
    end

    def change?(*args, &block)
      block.change?(*args)
    end

    # Android-only.
    def main_activity
      MotionSpec.main_activity
    end

    private

    def build_ios_parent_context(context)
      p 'building parent context'
      (parent_context = self).methods(false).each do |e|
        class << context
          self
        end.send(:define_method, e) do |*args|
          parent_context.send(e, *args)
        end
      end
    end
  end
end
