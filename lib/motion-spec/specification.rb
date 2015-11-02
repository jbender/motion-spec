# -*- encoding : utf-8 -*-
module Motion
  module Spec
    class Specification
      MULTIPLE_POSTPONES_ERROR_MESSAGE =
        "Only one indefinite `wait' block at the same time is allowed!"

      attr_reader :description

      def initialize(context, description, block, before_filters, after_filters)
        @context, @description, @block = context, description, block
        @before_filters, @after_filters = before_filters.dup, after_filters.dup

        @postponed_blocks_count = 0
        @ran_spec_block = false
        @ran_after_filters = false
        @exception_occurred = false
        @error = ""
      end

      def postponed?
        @postponed_blocks_count != 0
      end

      def run_before_filters
        execute_block { @before_filters.each { |f| @context.instance_eval(&f) } }
      end

      def run_spec_block
        @ran_spec_block = true
        # If an exception occurred, we definitely don't need to perform the actual spec anymore
        unless @exception_occurred
          execute_block { @context.instance_eval(&@block) }
        end
        finish_spec unless postponed?
      end

      def run_after_filters
        @ran_after_filters = true
        execute_block { @after_filters.each { |f| @context.instance_eval(&f) } }
      end

      def run
        Motion::Spec.handle_requirement_begin(@description)
        Counter[:depth] += 1
        run_before_filters
        @number_of_requirements_before = Counter[:requirements]
        run_spec_block unless postponed?
      end

      def schedule_block(seconds, &block)
        # If an exception occurred, we definitely don't need to schedule any more blocks
        unless @exception_occurred
          @postponed_blocks_count += 1
          unless Platform.android?
            performSelector("run_postponed_block:", withObject:block, afterDelay:seconds)
          else
            sleep seconds
            run_postponed_block(block)
          end
        end
      end

      def postpone_block(timeout = 1, &block)
        # If an exception occurred, we definitely don't need to schedule any more blocks
        return if @exception_occurred
        raise MULTIPLE_POSTPONES_ERROR_MESSAGE if @postponed_block

        @postponed_blocks_count += 1
        @postponed_block = block

        return performSelector(
          "postponed_block_timeout_exceeded",
          withObject:nil,
          afterDelay:timeout
        ) unless Platform.android?

        sleep timeout
        postponed_block_timeout_exceeded
      end

      def postpone_block_until_change(object_to_observe, key_path, timeout = 1, &block)
        # If an exception occurred, we definitely don't need to schedule any more blocks
        return if @exception_occurred
        raise MULTIPLE_POSTPONES_ERROR_MESSAGE if @postponed_block

        @postponed_blocks_count += 1
        @postponed_block = block
        @observed_object_and_key_path = [object_to_observe, key_path]
        object_to_observe.addObserver(self, forKeyPath:key_path, options:0, context:nil)

        return performSelector(
          "postponed_change_block_timeout_exceeded",
          withObject:nil,
          afterDelay:timeout
        ) unless Platform.android?

        sleep timeout
        postponed_change_block_timeout_exceeded
      end

      def observeValueForKeyPath(key_path, ofObject:object, change:_, context:__)
        resume
      end

      def postponed_change_block_timeout_exceeded
        remove_observer!
        postponed_block_timeout_exceeded
      end

      def remove_observer!
        if @observed_object_and_key_path
          object, key_path = @observed_object_and_key_path
          object.removeObserver(self, forKeyPath:key_path)
          @observed_object_and_key_path = nil
        end
      end

      def postponed_block_timeout_exceeded
        cancel_scheduled_requests!
        execute_block { raise Error.new(:failed, "timeout exceeded: #{@context.name} - #{@description}") }
        @postponed_blocks_count = 0
        finish_spec
      end

      def resume
        unless Platform.android?
          NSObject.cancelPreviousPerformRequestsWithTarget(self, selector:'postponed_block_timeout_exceeded', object:nil)
          NSObject.cancelPreviousPerformRequestsWithTarget(self, selector:'postponed_change_block_timeout_exceeded', object:nil)
        end
        remove_observer!
        block, @postponed_block = @postponed_block, nil
        run_postponed_block(block)
      end

      def run_postponed_block(block)
        # If an exception occurred, we definitely don't need execute any more blocks
        execute_block(&block) unless @exception_occurred
        @postponed_blocks_count -= 1
        unless postponed?
          if @ran_after_filters
            exit_spec
          elsif @ran_spec_block
            finish_spec
          else
            run_spec_block
          end
        end
      end

      def finish_spec
        if !@exception_occurred && Counter[:requirements] == @number_of_requirements_before
          # the specification did not contain any requirements, so it flunked
          execute_block { raise Error.new(:missing, "empty specification: #{@context.name} #{@description}") }
        end
        run_after_filters
        exit_spec unless postponed?
      end

      def cancel_scheduled_requests!
        unless Platform.android?
          NSObject.cancelPreviousPerformRequestsWithTarget(@context)
          NSObject.cancelPreviousPerformRequestsWithTarget(self)
        end
      end

      def exit_spec
        cancel_scheduled_requests!
        Counter[:depth] -= 1
        Motion::Spec.handle_requirement_end(@error)
        @context.specification_did_finish(self)
      end

      def execute_block
        begin
          yield
        rescue Object => e
          @exception_occurred = true

          if e.is_a?(Exception)
            ErrorLog << "#{e.class}: #{e.message}\n"
            lines = $DEBUG ? e.backtrace : e.backtrace.find_all { |line| line !~ /bin\/macbacon|\/mac_bacon\.rb:\d+/ }
            lines.each_with_index { |line, i|
              ErrorLog << "\t#{line}#{i==0 ? ": #{@context.name} - #{@description}" : ""}\n"
            }
            ErrorLog << "\n"
          else
            if defined?(NSException)
              # Pure NSException.
              ErrorLog << "#{e.name}: #{e.reason}\n"
            else
              # Pure Java exception.
              ErrorLog << "#{e.class.toString} : #{e.getMessage}"
            end
          end

          @error = if e.kind_of? Error
            Counter[e.count_as] += 1
            "#{e.count_as.to_s.upcase} - #{e}"
          else
            Counter[:errors] += 1
            "ERROR: #{e.class} - #{e}"
          end
        end
      end
    end
  end
end
