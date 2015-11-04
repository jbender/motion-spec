# -*- encoding : utf-8 -*-
module MotionSpec
  module Matcher
    class Eql < SingleMethod
      def initialize(value)
        super(:eql?, value)
      end
    end
  end
end
