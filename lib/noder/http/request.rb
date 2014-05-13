module Noder
  module HTTP
    class Request
      attr_accessor :params
      attr_reader :env
      
      def initialize(env)
        @env = env
        @query = HTTP::Utils.parse(env[:query_string])
        @params = @query
        if env[:post_content] && env[:post_content] != ''
          @params.merge!(HTTP::Utils.parse(env[:post_content]))
        end
      end

      def headers
        @headers ||= HTTP::Utils.parse_headers(env[:headers])
      end

      def request_method
        env[:request_method]
      end

      def cookie
        env[:cookie]
      end

      def content_type
        env[:content_type]
      end

      def request_uri
        env[:request_uri]
      end

      def query_string
        env[:query_string]
      end

      def post_content
        env[:post_content]
      end

      def protocol
        env[:protocol]
      end

      def ip
        env[:ip]
      end
    end
  end
end
