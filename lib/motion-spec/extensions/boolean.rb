# -*- encoding : utf-8 -*-
class Object
  def true?
    false
  end

  def false?
    false
  end
end

class TrueClass
  def true?
    true
  end
end

class FalseClass
  def false?
    true
  end
end
