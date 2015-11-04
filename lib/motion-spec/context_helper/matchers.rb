module MotionSpec
  module ContextHelper
    module Matchers
      def be_nil
        MotionSpec::Matcher::BeNil.new
      end

      def be_true
        MotionSpec::Matcher::BeTrue.new
      end

      def be_false
        MotionSpec::Matcher::BeFalse.new
      end

      def raise_error(exception_class = Exception, message = "")
        MotionSpec::Matcher::RaiseError.new(exception_class, message)
      end
      alias_method :raise_exception, :raise_error

      def eql(value)
        MotionSpec::Matcher::Eql.new(value)
      end

      def be(value)
        MotionSpec::Matcher::Be.new(value)
      end
      alias_method :equal, :be

      def eq(value)
        MotionSpec::Matcher::Eq.new(value)
      end

      def match(regex)
        MotionSpec::Matcher::Match.new(regex)
      end

      def match_array(array)
        MotionSpec::Matcher::MatchArray.new(array)
      end
      alias_method :contain_exactly, :match_array

      def include(*values)
        MotionSpec::Matcher::Include.new(*values)
      end

      def have(number)
        MotionSpec::Matcher::HaveItems.new(number)
      end

      def satisfy(&block)
        MotionSpec::Matcher::Satisfy.new(&block)
      end

      def respond_to(method_name)
        MotionSpec::Matcher::RespondTo.new(method_name)
      end

      def start_with(substring)
        MotionSpec::Matcher::StartWith.new(substring)
      end

      def end_with(substring)
        MotionSpec::Matcher::EndWith.new(substring)
      end

      def change(&change_block)
        MotionSpec::Matcher::Change.new(change_block)
      end

      def be_within(range)
        MotionSpec::Matcher::BeWithin.new(range)
      end

      def method_missing(method_name, *args, &block)
        string_method_name = method_name.to_s
        match_be = string_method_name.match(/^be_(.*)/)

        if match_be
          return MotionSpec::Matcher::BeGeneric.new(match_be[1], *args)
        end

        match_have = string_method_name.match(/^have_(.*)/)

        if match_have
          return MotionSpec::Matcher::HaveGeneric.new(match_have[1], *args)
        end

        super
        # raise "method name not found #{method_name}"
      end
    end
  end
end
