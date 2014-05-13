require 'evma_httpserver'
require 'socket'

module Noder
  module HTTP
    class Connection < EM::Connection
      include EventMachine::HttpServer

      attr_accessor :app, :environment, :request_stack, :settings

      def initialize(*args)
        super(*args)
        @settings = args[1]
      end
      
      def post_init
        super
        if settings[:enable_ssl]
          start_tls(:private_key_file => settings[:ssl_key], :cert_chain_file => settings[:ssl_cert], :verify_peer => false)
        end
      end

      def process_http_request
        env = {
          connection: self,
          request_env: request_env,
          request: nil,
          response: nil
        }
        EM.defer do
          request_stack.call(env)
        end
      end

      def request_env
        port, ip = Socket.unpack_sockaddr_in(get_peername)
        {
          request_method: @http_request_method,
          cookie: @http_cookie,
          content_type: @http_content_type,
          path_info: @http_path_info,
          request_uri: @http_request_uri,
          query_string: @http_query_string,
          post_content: @http_post_content,
          headers: @http_headers,
          protocol: @http_protocol,
          ip: ip
        }
      end
    end
  end
end
