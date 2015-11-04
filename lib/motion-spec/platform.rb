# -*- encoding : utf-8 -*-
module MotionSpec
  class Platform
    def self.android?
      defined?(NSObject) ? false : true
    end
  end
end
