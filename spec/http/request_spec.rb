require 'spec_helper'

describe Noder::HTTP::Request do
  describe '#intialize' do
    it 'sets the params from the query string' do
      env = {
        query_string: 'foo=bar&baz=1'
      }
      request = described_class.new(env)
      request.params.should == { 'foo' => 'bar', 'baz' => '1' }
    end

    it 'sets the params from the POST content' do
      env = {
        post_content: 'foo=bar&baz=1'
      }
      request = described_class.new(env)
      request.params.should == { 'foo' => 'bar', 'baz' => '1' }
    end

    it 'sets the params from the query string and POST content' do
      env = {
        query_string: 'foo=bar&baz=1',
        post_content: 'postfoo=bar&postbaz=1'
      }
      request = described_class.new(env)
      request.params.should == { 'foo' => 'bar', 'baz' => '1', 'postfoo' => 'bar', 'postbaz' => '1' }
    end
  end
end
