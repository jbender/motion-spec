# -*- encoding : utf-8 -*-
class Object
  # Creates a proxy method on an object.  In this setup, it places an expectation on an object (like a mock)
  # but still calls the original method.  So if you want to make sure the method is called and still return
  # its value, or simply want to invoke the side effects of a method and return a stubbed value, then you can
  # do that.
  #
  # ==== Examples
  #
  #     class Parrot
  #       def speak!
  #         puts @words
  #       end
  #
  #       def say_this(words)
  #         @words = words
  #         "I shall say #{words}!"
  #       end
  #     end
  #
  #     # => test/your_test.rb
  #     sqawky = Parrot.new
  #     sqawky.proxy!(:say_this)
  #     # Proxy method still calls original method...
  #     sqawky.say_this("hey")   # => "I shall say hey!"
  #     sqawky.speak!            # => "hey"
  #
  #     sqawky.proxy!(:say_this, "herro!")
  #     # Even though we return a stubbed value...
  #     sqawky.say_this("these words")   # => "herro!"
  #     # ...the side effects are still there.
  #     sqawky.speak!                    # => "these words"
  #
  # TODO: This implementation is still very rough.  Needs refactoring and refining.  Won't
  # work on ActiveRecord attributes, for example.
  #
  def proxy!(method, options = {}, &block)
    MotionSpec::Mocks.add([self, method])

    if respond_to?(method)
      proxy_existing_method(method, options, &block)
    else
      proxy_missing_method(method, options, &block)
    end
  end

  protected

  def proxy_existing_method(method, options = {}, &_block)
    method_alias = "__old_#{method}".to_sym

    meta_eval { module_eval { alias_method method_alias, method } }

    check_arity = proc do |args|
      arity = method(method_alias.to_sym).arity

      # Negative arity means some params are optional, so we check for the
      # minimum required. Sadly, we can't tell what the maximum is.
      has_mimimum_arguments =
        if arity >= 0
          args.length != arity
        else
          args.length < ~arity
        end

      fail ArgumentError unless has_mimimum_arguments
    end

    default_operation =
      lambda do |*args|
        check_arity.call(args)

        MotionSpec::Mocks.verify([self, method])

        if method(method_alias.to_sym).arity == 0
          send(method_alias)
        else
          send(method_alias, *args)
        end
      end

    behavior =
      if options[:return]
        lambda do |*args|
          default_operation.call(*args)
          return options[:return]
        end
      else
        default_operation
      end

    meta_def method, &behavior
  end

  def proxy_missing_method(method, options = {}, &_block)
    default_operation =
      lambda do |*args|
        MotionSpec::Mocks.verify([self, method])

        method_missing(method, args)
      end

    behavior =
      if options[:return]
        lambda do |*args|
          default_operation.call(*args)
          return options[:return]
        end
      else
        default_operation
      end

    meta_def method, &behavior
  end
end
