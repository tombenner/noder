require 'spec_helper'

describe Noder::HTTP::Response do
  let(:response) do
    request = double
    request.stub(:params) { {} }
    env = {
      request: request
    }
    response = described_class.new(env)
    response.stub(:send_data)
    response.stub(:close_connection_after_writing)
    response
  end

  describe '#intialize' do
    it 'sets the params' do
      request = double
      request.stub(:params) { { 'foo' => 'bar' } }
      env = {
        request: request
      }
      response = described_class.new(env)
      response.stub(:send_data)
      response.stub(:close_connection_after_writing)
      response.params.should == { 'foo' => 'bar' }
    end
  end

  describe '#write' do
    it 'appends the content' do
      response.write('foo')
      response.content.should == 'foo'
      response.write('bar')
      response.content.should == 'foobar'
    end
  end

  describe '#write_head' do
    it 'sets the status' do
      response.write_head(123)
      response.status.should == 123
    end

    it 'sets the status and headers' do
      response.write_head(123, { 'foo' => 'bar' })
      response.status.should == 123
      response.headers.should == { 'foo' => 'bar' }
    end

    it 'appends the headers' do
      response.headers = { 'foo' => 'bar' }
      response.write_head(123, { 'bar' => 'baz' })
      response.headers.should == { 'foo' => 'bar', 'bar' => 'baz' }
    end
  end

  describe '#set_header' do
    it 'sets the header' do
      response.set_header('foo', 'bar')
      response.headers.should == { 'foo' => 'bar' }
    end
  end

  describe '#get_header' do
    it 'gets the header' do
      response.headers = { 'foo' => 'bar' }
      response.get_header('foo').should == 'bar'
    end
  end

  describe '#remove_header' do
    it 'removes the header' do
      response.headers = { 'foo' => 'bar' }
      response.remove_header('foo')
      response.headers.should == {}
    end
  end

  describe '#end' do
    it 'calls send_response' do
      response.should_receive(:send_response)
      response.end
    end

    it 'sets is_rendered to true' do
      response.is_rendered?.should be_false
      response.end
      response.is_rendered?.should be_true
    end
  end
end
