# -*- encoding : utf-8 -*-
module MotionSpec
  class Should
    # Kills ==, ===, =~, eql?, equal?, frozen?, instance_of?, is_a?,
    # kind_of?, nil?, respond_to?, tainted?
    #
    # The reason that these methods are killed is so that method_missing
    # will catch them and push them through `satisfy`. The satisfy method
    # handles chaining and negation (eg .should.not.eq).
    instance_methods.each { |name| undef_method name if name =~ /\?|^\W+$/ }

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
      if args.size == 1 && String === args.first
        description = args.shift
      else
        description = ''
      end

      result = yield(@object, *args)

      if Counter[:depth] > 0
        Counter[:requirements] += 1
        flunk(description) unless @negated ^ result
        result
      else
        @negated ? !result : !!result
      end
    end

    def method_missing(name, *args, &block)
      name = "#{name}?" if name.to_s =~ /\w[^?]\z/

      desc = @negated ? 'not ' : ''
      desc << @object.inspect << '.' << name.to_s
      desc << '(' << args.map(&:inspect).join(', ') << ') failed'

      satisfy(desc) do |object|
        object.__send__(name, *args, &block)
      end
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

    # TODO: This was in the MacBacon specs and kept for backwards compatibilty
    # but I've never seen this used before so possibly kill this.
    def eq=(value)
      self === value
    end

    def flunk(reason = 'Flunked')
      raise Error.new(:failed, reason)
    end
  end
end
