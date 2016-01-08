# -*- encoding : utf-8 -*-
module MotionSpec
  module Matcher
    class BeA
      def initialize(test_class)
        @test_class = test_class
      end

      def matches?(subject)
        comparison_object = subject.is_a?(Class) ? subject : subject.class

        comparison_object.ancestors.include? @test_class
      end

      def fail!(subject, negated)
        message = FailMessageRenderer.message_for_be_a(negated, subject, @test_class)
        fail FailedExpectation.new(message)
      end
    end
  end
end
