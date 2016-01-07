# -*- encoding : utf-8 -*-
module MotionSpec
  module Matcher
    class BeTrue
      def matches?(value)
        value == true
      end

      def fail!(subject, negated)
        fail FailedExpectation.new(
          FailMessageRenderer.message_for_be_true(negated, subject)
        )
      end
    end
  end
end
