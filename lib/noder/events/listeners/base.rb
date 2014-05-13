module Noder
  module Events
    module Listeners
      class Base
        attr_accessor :callback
        
        def initialize(callback)
          @callback = callback
        end
      end
    end
  end
end
