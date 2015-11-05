# -*- encoding : utf-8 -*-
module MotionSpec
  class Context
    def expect_failure(fail_message = '', &block)
      expect(&block).to raise_error(FailedExpectation, fail_message)
    end
  end
end
