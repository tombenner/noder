require 'net/http'
require 'uri'

module ServerIntegrationHelper
  def self.included(base)
    base.let(:request_response_block) do
      proc do |request, response|
        request.should be_a(Repress::Request)
        response.should be_a(Repress::Response)
      end
    end

    base.let(:server) { create_server }
  end

  def create_and_start_server(options={}, &block)
    server = create_server(options, &block)
    start_server(server)
    server
  end

  def create_server(options={}, &block)
    wait_for_em_cleanup
    defaults = {
      port: port
    }
    options = defaults.merge(options)
    server = Noder::HTTP::Server.new(options, &block)
    server
  end

  def http_get(path=nil)
    Net::HTTP.get_response(server_uri(path))
  end

  def https_get(path=nil)
    uri = server_uri(path, protocol: 'https')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.get(uri.request_uri)
  end

  def http_post(path=nil, options={})
    defaults = {
      params: {}
    }
    options = defaults.merge(options)
    Net::HTTP.post_form(server_uri(path), options[:params])
  end

  def server_uri(path=nil, options={})
    defaults = {
      protocol: 'http'
    }
    options = defaults.merge(options)
    URI.parse("#{options[:protocol]}://#{address}:#{port}#{path}")
  end

  def start_server(server)
    Thread.new { server.listen }
    sleep 0.1
  end

  def address
    '127.0.0.1'
  end

  def port
    8008
  end
  
  def get_empty_block
    proc {}
  end

  def with_em(&block)
    wait_for_em_cleanup
    Thread.new do
      EM.synchrony do
        block.call
      end
    end
    sleep 0.1
    EM.stop
  end

  def wait_for_em_cleanup
    sleep 0.1
  end
end
