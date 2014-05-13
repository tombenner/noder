require 'spec_helper'

describe Noder::HTTP::Request do
  include ServerIntegrationHelper

  describe '#headers' do
    it 'returns the parsed headers' do
      block = proc do |request, response|
        request.headers.should include({ 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
        response.end
      end
      block.should_receive(:call).and_call_original
      server = create_and_start_server(&block)
      http_get
      server.close
    end
  end

  describe '#params' do
    it 'returns the params from the query string' do
      block = proc do |request, response|
        request.params.should == { 'foo' => 'bar', 'baz' => '1' }
        response.end
      end
      block.should_receive(:call).and_call_original
      server = create_and_start_server(&block)
      http_get('/?foo=bar&baz=1')
      server.close
    end

    it 'returns the params from the POST content' do
      block = proc do |request, response|
        request.params.should == { 'foo' => 'bar', 'baz' => '1' }
        response.end
      end
      block.should_receive(:call).and_call_original
      server = create_and_start_server(&block)
      http_post('/', params: { 'foo' => 'bar', 'baz' => '1' })
      server.close
    end

    it 'returns the params from the query string and POST content' do
      block = proc do |request, response|
        request.params.should == { 'foo' => 'bar', 'baz' => '1', 'postfoo' => 'bar', 'postbaz' => '1' }
        response.end
      end
      block.should_receive(:call).and_call_original
      server = create_and_start_server(&block)
      http_post('/?foo=bar&baz=1', params: { 'postfoo' => 'bar', 'postbaz' => '1' })
      server.close
    end
  end

  describe '#request_method' do
    it 'returns the method for a GET request' do
      block = proc do |request, response|
        request.request_method.should == 'GET'
        response.end
      end
      block.should_receive(:call).and_call_original
      server = create_and_start_server(&block)
      http_get
      server.close
    end

    it 'returns the method for a POST request' do
      block = proc do |request, response|
        request.request_method.should == 'POST'
        response.end
      end
      block.should_receive(:call).and_call_original
      server = create_and_start_server(&block)
      http_post
      server.close
    end
  end

  describe '#request_uri' do
    it 'returns the path without the query string' do
      block = proc do |request, response|
        request.request_uri.should == '/foo'
        response.end
      end
      block.should_receive(:call).and_call_original
      server = create_and_start_server(&block)
      http_get('/foo?bar=baz')
      server.close
    end
  end

  describe '#query_string' do
    it 'returns the query string' do
      block = proc do |request, response|
        request.query_string.should == 'bar=baz&foo=1'
        response.end
      end
      block.should_receive(:call).and_call_original
      server = create_and_start_server(&block)
      http_get('/foo?bar=baz&foo=1')
      server.close
    end
  end

  describe '#protocol' do
    it 'returns the protocol' do
      block = proc do |request, response|
        request.protocol.should == 'HTTP/1.1'
        response.end
      end
      block.should_receive(:call).and_call_original
      server = create_and_start_server(&block)
      http_get
      server.close
    end
  end

  describe '#ip' do
    it 'returns the IP address' do
      block = proc do |request, response|
        request.ip.should == '127.0.0.1'
        response.end
      end
      block.should_receive(:call).and_call_original
      server = create_and_start_server(&block)
      http_get
      server.close
    end
  end
end
