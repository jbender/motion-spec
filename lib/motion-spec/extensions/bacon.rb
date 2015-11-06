# -*- encoding : utf-8 -*-

# There are gems (e.g. motion-stump) that rely on Bacon or some of its
# sub-modules to exist so they can extend them. This file ensures that
# MotionSpec can be used alongside those gems but may break some functionality.
module Bacon
  class Context < MotionSpec::Context
  end
end
