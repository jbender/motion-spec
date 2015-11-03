# -*- encoding : utf-8 -*-
module MotionSpec
  module FastOutput
    def handle_specification_begin(name); end
    def handle_specification_end; end

    def handle_requirement_begin(description); end
    def handle_requirement_end(error)
      return if error.empty?
      print error[0..0]
    end

    def handle_summary
      puts "", "Finished in #{Time.now - @timer} seconds."
      puts ErrorLog  if Backtraces
      puts "%d tests, %d assertions, %d failures, %d errors" %
        Counter.values_at(:specifications, :requirements, :failed, :errors)
    end
  end
end
