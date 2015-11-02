# -*- encoding : utf-8 -*-
module Motion
  module Spec
    module KnockOutput
      def handle_specification_begin(name); end
      def handle_specification_end        ; end

      def handle_requirement_begin(description)
        @description = description
        ErrorLog.replace ""
      end

      def handle_requirement_end(error)
        if error.empty?
          puts "ok - %s" % [@description]
        else
          puts "not ok - %s: %s" % [@description, error]
          puts ErrorLog.strip.gsub(/^/, '# ')  if Backtraces
        end
      end

      def handle_summary;  end
    end
  end
end
