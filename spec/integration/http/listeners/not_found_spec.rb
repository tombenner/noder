require 'spec_helper'

describe Noder::HTTP::Listeners::NotFound do
  include ServerIntegrationHelper

  describe '#call' do
    it 'renders a 404 when a response has not been rendered yet' do
      server = create_server
      start_server(server)
      http_get.code.should == '404'
      server.close
    end
  end
end
