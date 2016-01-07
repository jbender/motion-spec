# -*- encoding : utf-8 -*-
module MotionSpec
  module Matcher
    class Satisfy
      def initialize(&condition_block)
        @condition_block = condition_block
      end

      def matches?(*values)
        @condition_block.call(*values)
      end

      def fail!(_subject, negated)
        fail FailedExpectation.new(
          FailMessageRenderer.message_for_satisfy(negated)
        )
      end
    end
  end
end
