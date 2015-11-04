# -*- encoding : utf-8 -*-
module MotionSpec
  module ColorizedOutput
    GREEN = "\033[0;32m"
    RED   = "\033[0;31m"
    RESET = "\033[00m"

    def handle_specification_begin(name); end
    def handle_specification_end; end

    def handle_requirement_begin(description); end

    def handle_requirement_end(error)
      if error.empty?
        print "#{GREEN}.#{RESET}"
      else
        print "#{RED}#{error[0..0]}#{RESET}"
      end
    end

    def handle_summary
      puts ''
      puts '', ErrorLog  if Backtraces && !ErrorLog.empty?

      duration = '%0.2f' % (Time.now - @timer)
      puts '', "Finished in #{duration} seconds."

      failure = Counter[:errors] > 0 || Counter[:failed] > 0
      color = failure ? RED : GREEN

      puts "#{color}%d tests, %d assertions, %d failures, %d errors#{RESET}" %
        Counter.values_at(:specifications, :requirements, :failed, :errors)
      puts ''
    end
  end
end
