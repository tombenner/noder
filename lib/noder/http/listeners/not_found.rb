module Noder
  module HTTP
    module Listeners
      class NotFound < Events::Listeners::Base
        def call(env)
          callback.call(env) if callback
          response = env[:response]
          render_not_found(response) unless response.is_rendered?
          env
        end

        def render_not_found(response)
          response.status_code = 404
          response.write('Not Found')
          response.end
        end
      end
    end
  end
end
