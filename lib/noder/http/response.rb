module Noder
  module HTTP
    class Response < EventMachine::DelegatedHttpResponse
      attr_accessor :params

      def initialize(env)
        super(env[:connection])
        @params = env[:request].params
        @is_rendered = false
      end

      def write(content)
        self.content ||=  ''
        self.content << content
      end

      def write_head(status, headers={})
        self.status = status
        @headers.merge!(headers)
      end

      def status_code=(status)
        self.status = status
      end

      def status_code
        self.status
      end

      def set_header(name, value)
        @headers[name] = value
      end

      def get_header(name)
        @headers[name]
      end

      def remove_header(name)
        @headers.delete(name)
      end

      def end(content=nil)
        return if @is_rendered
        @is_rendered = true
        write(content) if content
        send_response
      end

      def is_rendered?
        @is_rendered
      end

      protected

      def app
        @delegate.app
      end

      def request_env
        @delegate.request_env
      end
    end
  end
end
