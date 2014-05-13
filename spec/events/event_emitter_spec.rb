require 'spec_helper'

describe Noder::Events::EventEmitter do
  include ServerIntegrationHelper
  
  class Dummy
    include Noder::Events::EventEmitter
  end

  let(:dummy) { Dummy.new }
  let(:event) { 'foo' }

  describe '#on' do
    it 'adds listeners' do
      dummy.listeners(event).should == []
      dummy.on(event, proc {})
      dummy.listeners(event).length.should == 1
      dummy.on(event, proc {})
      dummy.listeners(event).length.should == 2
    end
  end

  describe '#remove_listener' do
    it 'removes listeners' do
      callback1 = proc { 1 }
      callback2 = proc { 2 }
      dummy.on(event, &callback1)
      dummy.on(event, &callback2)

      dummy.listeners(event).index(callback1).should == 0
      dummy.remove_listener(event, callback1)
      dummy.listeners(event).index(callback1).should be_nil
      
      dummy.listeners(event).index(callback2).should == 0
      dummy.remove_listener(event, callback2)
      dummy.listeners(event).index(callback2).should be_nil
    end
  end

  describe '#remove_all_listeners' do
    it 'removes all listeners' do
      dummy.on(event, proc {})
      dummy.on(event, proc {})
      dummy.listeners(event).length.should == 2
      dummy.remove_all_listeners(event)
      dummy.listeners(event).length.should == 0
    end
  end

  describe '#set_max_listeners' do
    it 'logs a warning if the max is exceeded' do
      dummy.set_max_listeners(event, 1)
      dummy.on(event, proc {})
      Noder.logger.should_receive(:warn).with('Maximum listener count exceeded for Dummy (max count is 1; current count is 1).')
      dummy.on(event, proc {})
    end
  end

  describe '#listeners' do
    it 'returns the listeners' do
      callback1 = proc { 1 }
      callback2 = proc { 2 }
      dummy.on(event, &callback1)
      dummy.on(event, &callback2)
      dummy.listeners(event).should == [callback1, callback2]
    end
  end

  describe '#emit' do
    it 'emits the events' do
      callback1 = proc {}
      callback2 = proc {}
      dummy.on(event, &callback1)
      dummy.on(event, &callback2)
      callback1.should_receive(:call).ordered
      callback2.should_receive(:call).ordered
      with_em do
        dummy.emit(event)
      end
    end
  end
end
