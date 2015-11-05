# -*- encoding : utf-8 -*-
module MotionSpec
  module ContextHelper
    module Should
      def should(*args, &block)
        return it('should ' + args.first, &block) if Counter[:depth] == 0

        super(*args, &block)
      end
    end
  end
end
