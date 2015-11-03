# -*- encoding : utf-8 -*-
module Kernel
  private

  def describe(*args, &block)
    p 'describing via Kernel'
    MotionSpec::Context.new(args.join(' '), &block)
  end
  alias_method :context, :describe

  def shared(name, &block)
    MotionSpec::Shared[name] = block
  end
end
