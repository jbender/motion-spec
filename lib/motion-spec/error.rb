# -*- encoding : utf-8 -*-
module MotionSpec
  class Error < RuntimeError
    attr_accessor :count_as

    def initialize(count_as, message)
      @count_as = count_as
      super message
    end
  end
end
