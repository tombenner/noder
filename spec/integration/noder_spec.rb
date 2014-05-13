require 'spec_helper'

describe Noder do
  include ServerIntegrationHelper

  describe '.with' do
    it 'performs the operation and callback' do
      block = proc do |request, response|
        operation = -> { request.should be_a(Noder::HTTP::Request); 'foo' }
        callback = ->(result) { result.should == 'foo' }
        operation.should_receive(:call).ordered.and_call_original
        callback.should_receive(:call).ordered.and_call_original
        Noder.with operation, callback
        response.end
      end
      block.should_receive(:call).and_call_original
      server = create_and_start_server(&block)
      http_get
      server.close
    end

    it 'performs the operation and block' do
      block = proc do |request, response|
        operation = -> { request.should be_a(Noder::HTTP::Request); 'foo' }
        callback = ->(result) { result.should == 'foo' }
        operation.should_receive(:call).ordered.and_call_original
        callback.should_receive(:call).ordered.and_call_original
        Noder.with operation, &callback
        response.end
      end
      block.should_receive(:call).and_call_original
      server = create_and_start_server(&block)
      http_get
      server.close
    end
  end
end
