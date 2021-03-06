# -*- encoding : utf-8 -*-
module MotionSpec
  module ContextHelper
    module MemoizedHelpers
      attr_accessor :__memoized

      def let(name, &block)
        fail '#let or #subject called without a block' unless block_given?

        (class << self; self; end).class_eval do
          define_method(name) do
            self.__memoized ||= {}
            __memoized.fetch(name) { __memoized[name] = block.call }
          end
        end

        # The way that nested contexts are implemented requires us to manually
        # reset any memoized values after each spec via an 'after'.
        after { reset_memoized }
      end

      def let!(name, &block)
        let(name, &block)
        before { __send__(name) }
      end

      def subject(name = nil, &block)
        let(name, &block) if name

        let(:subject, &block)
      end

      def subject!(name = nil, &block)
        subject(name, &block)
        before { subject }
      end

      def is_expected # rubocop:disable Style/PredicateName
        expect(subject)
      end

      def reset_memoized
        @__memoized = nil
        parent_context.reset_memoized if respond_to?(:parent_context)
      end
    end
  end
end
