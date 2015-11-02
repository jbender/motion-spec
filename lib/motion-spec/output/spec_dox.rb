# -*- encoding : utf-8 -*-
module Motion
  module Spec
    module SpecDoxOutput
      def handle_specification_begin(name)
        puts spaces + name
      end

      def handle_specification_end
        puts if Counter[:context_depth] == 1
      end

      def handle_requirement_begin(description)
        print "#{spaces}  - #{description}"
      end

      def handle_requirement_end(error)
        puts error.empty? ? "" : " [#{error}]"
      end

      def handle_summary
        print ErrorLog  if Backtraces
        puts "%d specifications (%d requirements), %d failures, %d errors" %
          Counter.values_at(:specifications, :requirements, :failed, :errors)
      end

      def spaces
        "  " * (Counter[:context_depth] - 1)
      end
    end
  end
end
