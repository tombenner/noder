require 'spec_helper'

describe Noder::HTTP::Response do
  include ServerIntegrationHelper

  describe '#write' do
    it 'writes the body' do
      block = proc do |request, response|
        response.write('foo')
        response.end
      end
      server = create_and_start_server(&block)
      http_get.body.should == 'foo'
      server.close
    end

    it 'appends to the body' do
      block = proc do |request, response|
        response.write('foo')
        response.write('bar')
        response.end
      end
      server = create_and_start_server(&block)
      http_get.body.should == 'foobar'
      server.close
    end
  end

  describe '#write_head' do
    it 'sets the status' do
      block = proc do |request, response|
        response.write_head(123)
        response.end
      end
      server = create_and_start_server(&block)
      http_get.code.should == '123'
      server.close
    end

    it 'sets the status and headers' do
      block = proc do |request, response|
        response.write_head(123, { 'foo' => 'bar', 'bar' => 'baz' })
        response.end
      end
      server = create_and_start_server(&block)
      response = http_get
      response.code.should == '123'
      response.header['foo'].should == 'bar'
      response.header['bar'].should == 'baz'
      server.close
    end
  end

  describe '#status_code=' do
    it 'sets the status' do
      block = proc do |request, response|
        response.status_code = 123
        response.end
      end
      server = create_and_start_server(&block)
      http_get.code.should == '123'
      server.close
    end
  end

  describe '#set_header' do
    it 'sets the header' do
      block = proc do |request, response|
        response.set_header('foo', 'bar')
        response.end
      end
      server = create_and_start_server(&block)
      http_get.header['foo'].should == 'bar'
      server.close
    end
  end
end
