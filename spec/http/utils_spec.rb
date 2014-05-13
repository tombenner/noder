require 'spec_helper'

describe Noder::HTTP::Utils do
  describe '.parse_headers' do
    it 'parses the headers' do
      headers = "Host: localhost:8000\x00Connection: keep-alive\x00Cache-Control: max-age=0\x00Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8\x00\x00"
      described_class.parse_headers(headers).should == {
        "Host"=>"localhost:8000",
        "Connection"=>"keep-alive",
        "Cache-Control"=>"max-age=0",
        "Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
      }
    end
  end
end
