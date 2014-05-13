require 'spec_helper'

describe Noder::HTTP::Server do
  include ServerIntegrationHelper

  describe '#on' do
    context "'request' event" do
      it 'calls the block when a request is made' do
        block = proc do |request, response|
          response.end
        end
        server = create_server
        server.on('request', &block)
        start_server(server)
        block.should_receive(:call).and_call_original
        http_get
        server.close
      end
    end

    context "'close' event" do
      it 'calls the block on #close' do
        block = proc {}
        server = create_server
        server.on('request') do |request, response|
          response.end
        end
        server.on('close', &block)
        start_server(server)
        http_get
        block.should_receive(:call).and_call_original
        server.close
      end
    end

    context 'SSL enabled' do
      it 'supports HTTPS requests' do
        block = proc do |request, response|
          response.end('foo')
        end
        options = {
          enable_ssl: true,
          ssl_key: File.expand_path('../../../support/certs/key.pem', __FILE__),
          ssl_cert: File.expand_path('../../../support/certs/cert.pem', __FILE__)
        }
        server = create_and_start_server(options, &block)
        block.should_receive(:call).and_call_original
        https_get.body.should == 'foo'
        server.close
      end
    end
  end
end
