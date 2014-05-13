module Noder
  module HTTP
    module Listeners
      class Response < Events::Listeners::Base
        def call(env)
          env[:response] ||= Noder::HTTP::Response.new(env)
          callback.call(env) if callback
          env
        end
      end
    end
  end
end
