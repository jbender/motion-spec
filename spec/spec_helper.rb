motion_require '../lib/motion-spec'

# module Bacon
#   class Specification
#     alias_method :_real_finish_spec, :finish_spec
#   end
#
#   class Context
#     def failures_before
#       @failures_before
#     end
#
#     def expect_spec_to_fail!
#       @failures_before = Motion::Spec::Counter[:failed]
#       Motion::Spec::Specification.class_eval do
#         def finish_spec
#           @exception_occurred.should.eq true
#           @exception_occurred = nil
#           Motion::Spec::Counter[:failed].should.eq @context.failures_before + 1
#           Motion::Spec::Counter[:failed] = @context.failures_before
#           self.class.class_eval { alias_method :finish_spec, :_real_finish_spec }
#           _real_finish_spec
#         end
#       end
#     end
#   end
# end
