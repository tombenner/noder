module Noder
  module HTTP
    module Listeners
      class Request < Events::Listeners::Base
        def call(env)
          env[:request] ||= Noder::HTTP::Request.new(env[:request_env])
          callback.call(env) if callback
          env
        end
      end
    end
  end
end
