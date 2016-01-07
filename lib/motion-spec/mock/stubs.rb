# -*- encoding : utf-8 -*-
module MotionSpec
  class Stubs
    class << self
      def add(object, method)
        stubs << [object, method]
      end

      def stubs
        @stubs ||= []
      end

      def clear!
        stubs.each { |object, method| object.reset(method) }
      end
    end
  end
end
