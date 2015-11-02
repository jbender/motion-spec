class Should
  # Kills ==, ===, =~, eql?, equal?, frozen?, instance_of?, is_a?,
  # kind_of?, nil?, respond_to?, tainted?
  # instance_methods.each { |name| undef_method name  if name =~ /\?|^\W+$/ }

  def initialize(object)
    @object = object
    @negated = false
  end

  def not(*args, &block)
    @negated = !@negated

    return self if args.empty?

    be(*args, &block)
  end

  def be(*args, &block)
    return self if args.empty?

    block = args.shift unless block_given?
    satisfy(*args, &block)
  end
  alias_method :a,  :be
  alias_method :an, :be

  def satisfy(*args, &block)
    p args

    if args.size == 1 && String === args.first
      description = args.shift
    else
      description = ""
    end

    r = yield(@object, *args)
    if Motion::Spec::Counter[:depth] > 0
      Motion::Spec::Counter[:requirements] += 1
      raise Motion::Spec::Error.new(:failed, description)  unless @negated ^ r
      r
    else
      @negated ? !r : !!r
    end
  end

  def method_missing(name, *args, &block)
    name = "#{name}?"  if name.to_s =~ /\w[^?]\z/

    desc = @negated ? "not " : ""
    desc << @object.inspect << "." << name.to_s
    desc << "(" << args.map{|x|x.inspect}.join(", ") << ") failed"

    satisfy(desc) { |x| x.__send__(name, *args, &block) }
  end

  def equal(value)
    self == value
  end
  alias_method :eq, :equal

  def match(value)
    self =~ value
  end

  def identical_to(value)
    self.equal? value
  end
  alias_method :same_as, :identical_to

  def flunk(reason="Flunked")
    raise Motion::Spec::Error.new(:failed, reason)
  end
end
