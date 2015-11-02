# -*- encoding : utf-8 -*-
class Numeric
  def close?(to, delta)
    (to.to_f - self).abs <= delta.to_f  rescue false
  end
end
