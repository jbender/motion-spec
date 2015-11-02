module Motion
  module Spec
    module RubyMineOutput
      @@entered = false
      @@description = nil
      @@specification = nil
      @@started = nil

      def handle_specification_begin(name)
        unless @@entered
          puts "##teamcity[enteredTheMatrix timestamp = '#{java_time}']\n\n"
          @@entered = true
        end
        @@specification = name
        puts "##teamcity[testSuiteStarted timestamp = '#{java_time}' name = '#{escape_message(name)}']\n\n"
      end

      def handle_specification_end
        puts "##teamcity[testSuiteFinished timestamp = '#{java_time}' name = '#{escape_message(@@specification)}']\n\n" if Counter[:context_depth] == 1
      end

      def handle_requirement_begin(description)
        @@description = description
        @@started = Time.now
        puts "##teamcity[testStarted timestamp = '#{java_time}' captureStandardOutput = 'true' name = '#{escape_message(description)}']\n\n"
      end

      def handle_requirement_end(error)
        if !error.empty?
          puts "##teamcity[testFailed timestamp = '#{java_time}' message = '#{escape_message(error)}' name = '#{escape_message(@@description)}']\n\n"
        end
        duration = ((Time.now - @@started) * 1000).to_i
        puts "##teamcity[testFinished timestamp = '#{java_time}' duration = '#{duration}' name = '#{escape_message(@@description)}']\n\n"
      end

      def handle_summary
        print ErrorLog if Backtraces
        puts "%d specifications (%d requirements), %d failures, %d errors" %
                 Counter.values_at(:specifications, :requirements, :failed, :errors)
      end

      def spaces
        "  " * (Counter[:context_depth] - 1)
      end

      def java_time
        convert_time_to_java_simple_date(Time.now)
      end

      def escape_message(message)
        copy_of_text = String.new(message)

        copy_of_text.gsub!(/\|/, "||")

        copy_of_text.gsub!(/'/, "|'")
        copy_of_text.gsub!(/\n/, "|n")
        copy_of_text.gsub!(/\r/, "|r")
        copy_of_text.gsub!(/\]/, "|]")

        copy_of_text.gsub!(/\[/, "|[")

        begin
          copy_of_text.encode!('UTF-8') if copy_of_text.respond_to? :encode!
          copy_of_text.gsub!(/\u0085/, "|x") # next line
          copy_of_text.gsub!(/\u2028/, "|l") # line separator
          copy_of_text.gsub!(/\u2029/, "|p") # paragraph separator
        rescue
          # it is not an utf-8 compatible string :(
        end

        copy_of_text
      end

      def convert_time_to_java_simple_date(time)
        gmt_offset = time.gmt_offset
        gmt_sign = gmt_offset < 0 ? "-" : "+"
        gmt_hours = gmt_offset.abs / 3600
        gmt_minutes = gmt_offset.abs % 3600

        millisec = time.usec == 0 ? 0 : time.usec / 1000

        #Time string in Java SimpleDateFormat
        sprintf("#{time.strftime("%Y-%m-%dT%H:%M:%S.")}%03d#{gmt_sign}%02d%02d", millisec, gmt_hours, gmt_minutes)
      end
    end
  end
end
