# -*- encoding : utf-8 -*-
module MotionSpec
  module Matcher
    class RaiseError
      def initialize(error_class = Exception, message = '')
        @error_class = error_class.is_a?(Class) ? error_class : Exception
        @error_message = exception_matcher?(error_class) ? error_class : message
      end

      def matches?(_value, &block)
        block.call
        false
      rescue Exception => e
        @rescued_exception = e
        exception_matches(e)
      end

      def exception_matcher?(error_class)
        error_class.is_a?(String) || error_class.is_a?(Regexp)
      end

      def exception_matches(exception)
        return false unless exception.is_a?(@error_class)

        is_match =
          case @error_message
          when String
            exception.message.include?(@error_message)
          when Regexp
            @error_message.match(exception.message)
          else
            false
          end

        is_match ? true : false
      end

      def fail!(_subject, negated)
        show_class = @error_class != Exception
        show_message = !@error_message.is_a?(String) || !@error_message.empty?
        fail FailedExpectation.new(
          FailMessageRenderer.message_for_raise_error(
            negated, show_class, @error_class, show_message, @error_message,
            @rescued_exception
          )
        )
      end
    end
  end
end
