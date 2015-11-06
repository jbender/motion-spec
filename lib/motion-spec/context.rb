# -*- encoding : utf-8 -*-
module MotionSpec
  class Context
    include ContextHelper::Matchers
    include ContextHelper::Should
    include ContextHelper::Expectation
    include ContextHelper::MemoizedHelpers

    attr_reader :name, :block

    def initialize(name, before = nil, after = nil, &block)
      @name = name
      @before = before ? before.dup : []
      @after = after ? after.dup : []
      @block = block
      @specifications = []
      @current_specification_index = 0

      MotionSpec.add_context(self)

      instance_eval(&block)
    end

    def run
      # TODO: return unless name =~ RestrictContext

      if Platform.android?
        @specifications.each(&:run)
      else
        spec = current_specification
        return spec.performSelector('run', withObject: nil, afterDelay: 0) if spec
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

    def it_behaves_like(name, &block)
      describe("behaves like #{name}") do
        include_examples(name)
        instance_eval(&block) if block_given?
      end
    end
    alias_method :behaves_like, :it_behaves_like

    def include_examples(name)
      instance_eval(&Shared[name])
    end

    def it(description = '', &block)
      return unless description =~ RestrictName

      block ||= proc { should.flunk 'not implemented' }

      Counter[:specifications] += 1

      @specifications << Specification.new(
        self, description, block, @before, @after
      )
    end

    def describe(*args, &block)
      context = MotionSpec::Context.new("#{@name} #{args.join(' ')}", @before, @after, &block)

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
      parent_context = self

      # object.methods(false) returns duplicate method names where one ends in
      # a ':' (e.g. ['foo:', 'foo']). This was causing a low-level Ruby error:
      # Assertion failed: (b != NULL), function rb_vm_block_method_imp, file vm.cpp, line 3386.
      # To fix the issue we removed the 'foo:' version of the method names.
      methods = parent_context
        .methods(false)
        .map { |name| name.to_s.chomp(':') }
        .uniq

      context_eigenclass = (class << context; self; end)
      context_eigenclass.send(:define_method, :parent_context) { parent_context }

      methods.each do |method_name|
        next if context.respond_to?(method_name)

        context_eigenclass.send(:define_method, method_name) do |*args|
          parent_context.send(method_name, *args)
        end
      end
    end
  end
end
