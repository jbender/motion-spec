# -*- encoding : utf-8 -*-
module MotionSpec
  module TapOutput
    @@count = 1
    @@describe = ''

    def handle_specification_begin(name)
      @@describe << "#{name} "
    end

    def handle_specification_end
      @@describe = ''
    end

    def handle_requirement_begin(description)
      @description = @@describe + description
      @description.sub!(/^[#\s]+/, '')
      ErrorLog.replace ''
    end

    def handle_requirement_end(error)
      if error.empty?
        puts 'ok %-3d - %s' % [@@count, @description]
      else
        puts 'not ok %d - %s: %s' %
          [@@count, @description, error]
        puts ErrorLog.strip.gsub(/^/, '# ') if Backtraces
      end

      @@count += 1
    end

    def handle_summary
      puts "1..#{Counter[:specifications]}"
      puts '# %d tests, %d assertions, %d failures, %d errors' %
        Counter.values_at(:specifications, :requirements, :failed, :errors)
    end
  end
end
