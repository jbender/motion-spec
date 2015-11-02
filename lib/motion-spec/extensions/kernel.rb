module Kernel
  private

  def describe(*args, &block)
    Bacon::Context.new(args.join(' '), &block)
  end
  alias_method :context, :describe

  def shared(name, &block)
    Bacon::Shared[name] = block
  end
end
