module Kernel
  private

  def describe(*args, &block)
    Bacon::Context.new(args.join(' '), &block)
  end

  def shared(name, &block)
    Bacon::Shared[name] = block
  end

  alias_method :context, :describe
end
