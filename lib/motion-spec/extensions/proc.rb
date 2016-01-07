# -*- encoding : utf-8 -*-
class Proc
  def raise?(*exceptions)
    call
  rescue *(exceptions.empty? ? RuntimeError : exceptions) => e
    e
  else
    false
  end

  def throw?(sym)
    catch(sym) do
      call
      return false
    end
    true
  end

  def change?
    pre_result = yield
    call
    post_result = yield
    pre_result != post_result
  end
end
