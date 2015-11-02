module Motion
  module Spec
    class Platform
      def self.android?
        defined?(NSObject) ? false : true
      end
    end
  end
end
