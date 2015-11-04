module MotionSpec
  module ContextHelper
    module Expectation
      def expect(subject = nil, &block)
        MotionSpec::Expectation.new(subject, &block)
      end
    end
  end
end
