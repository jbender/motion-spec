# -*- encoding : utf-8 -*-
module MotionSpec
  module ContextHelper
    module Should
      def should(*args, &block)
        if Counter[:context_depth] == 0
          return it('should ' + args.first, &block)
        end

        super(*args, &block)
      end
    end
  end
end
