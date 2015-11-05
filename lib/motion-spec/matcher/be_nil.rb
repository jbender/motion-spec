# -*- encoding : utf-8 -*-
module MotionSpec
  module Matcher
    class BeNil
      def matches?(value)
        value == nil
      end

      def fail!(subject, negated)
        raise FailedExpectation.new(
          FailMessageRenderer.message_for_be_nil(negated, subject)
        )
      end
    end
  end
end
