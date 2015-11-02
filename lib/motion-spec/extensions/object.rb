# -*- encoding : utf-8 -*-
class Object
  def should(*args, &block)
    Should.new(self).be(*args, &block)
  end
end
