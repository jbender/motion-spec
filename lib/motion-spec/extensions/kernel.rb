module Kernel
  private

  def describe(*args, &block)
    p 'describing via Kernel'
    Motion::Spec::Context.new(args.join(' '), &block)
  end
  alias_method :context, :describe

  def shared(name, &block)
    Motion::Spec::Shared[name] = block
  end
end
