# -*- encoding : utf-8 -*-
module MotionSpec
  module Matcher
    class Change
      def initialize(change_block)
        @change_block = change_block
      end

      def by(amount)
        @change_amount = amount
        self
      end

      def matches?(_subject, &expectation_block)
        old_value = @change_block.call
        expectation_block.call
        new_value = @change_block.call
        if @change_amount
          @value_diff = new_value - old_value
          @value_diff == @change_amount
        else
          new_value != old_value
        end
      end

      def fail!(_subject, negated)
        fail FailedExpectation.new(
          FailMessageRenderer.message_for_change(
            negated, @change_amount, @value_diff
          )
        )
      end
    end
  end
end
