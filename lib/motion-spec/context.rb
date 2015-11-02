module Bacon
  class Context
    attr_reader :name, :block

    def initialize(name, before = nil, after = nil, &block)
      @name = name
      @before, @after = (before ? before.dup : []), (after ? after.dup : [])
      @block = block
      @specifications = []
      @current_specification_index = 0

      Bacon.add_context(self)

      instance_eval(&block)
    end

    def run
      # TODO
      #return  unless name =~ RestrictContext

      unless Platform.android?
        if spec = current_specification
          spec.performSelector("run", withObject:nil, afterDelay:0)
        else
          Bacon.context_did_finish(self)
        end
      else
        @specifications.each do |spec|
          spec.run
        end
        Bacon.context_did_finish(self)
      end
    end

    def current_specification
      @specifications[@current_specification_index]
    end

    def specification_did_finish(spec)
      unless Platform.android?
        if (@current_specification_index + 1) < @specifications.size
          @current_specification_index += 1
          run
        else
          Bacon.context_did_finish(self)
        end
      end
    end

    def before(&block); @before << block; end
    def after(&block);  @after << block; end

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
      if Counter[:depth]==0
        it('should '+args.first,&block)
      else
        super(*args,&block)
      end
    end

    def describe(*args, &block)
      context = Bacon::Context.new(args.join(' '), @before, @after, &block)
      # FIXME: fix RM-879 and RM-806
      unless Platform.android?
        (parent_context = self).methods(false).each {|e|
          class<<context; self end.send(:define_method, e) {|*args| parent_context.send(e, *args)}
        }
      end
      context
    end

    def wait(seconds = nil, &block)
      if seconds
        current_specification.schedule_block(seconds, &block)
      else
        current_specification.postpone_block(&block)
      end
    end

    def wait_max(timeout, &block)
      current_specification.postpone_block(timeout, &block)
    end

    def wait_for_change(object_to_observe, key_path, timeout = 1, &block)
      current_specification.postpone_block_until_change(object_to_observe, key_path, timeout, &block)
    end

    def resume
      current_specification.resume
    end

    def raise?(*args, &block); block.raise?(*args); end
    def throw?(*args, &block); block.throw?(*args); end
    def change?(*args, &block); block.change?(*args); end

    alias_method :context, :describe

    # Android-only.
    def main_activity; Bacon.main_activity; end
  end
end
