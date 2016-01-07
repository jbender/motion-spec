# -*- encoding : utf-8 -*-
# The meta-programming that allows us to pop methods on and off for mocking
class Object
  # The hidden singleton lurks behind everyone
  def metaclass
    class << self
      self
    end
  end

  def meta_eval(&block)
    metaclass.instance_eval &block
  end

  # Adds methods to a metaclass
  def meta_def(name, &method_body)
    meta_eval do
      define_method(name) { |*args, &block| method_body.call(*args, &block) }
    end
  end

  def safe_meta_def(name, &method_body)
    metaclass.remember_original_method(name)
    meta_def(name, &method_body)
  end

  # Defines an instance method within a class
  def class_def(name, &block)
    class_eval { define_method name, &block }
  end

  def reset(method_name)
    metaclass.restore_original_method(method_name)
  end

  protected

  def motion_spec_original_method_name(method_name)
    "__original_#{method_name}".to_sym
  end

  def remember_original_method(method_name)
    if method_defined?(method_name)
      alias_method motion_spec_original_method_name(method_name), method_name
    end
    self
  end

  def restore_original_method(method_name)
    original_method_name = motion_spec_original_method_name(method_name)
    if method_defined?(original_method_name)
      alias_method method_name, original_method_name
      remove_method original_method_name
    end
    self
  end
end
