require 'eventmachine'
require 'logger'

directory = File.dirname(File.absolute_path(__FILE__))
Dir.glob("#{directory}/noder/*.rb") { |file| require file }

module Noder
  class << self
    def logger
      @logger ||= Logger.new(STDOUT)
    end

    def logger=(logger)
      @logger = logger
    end

    def with(operation, callback=nil, &block)
      EM.defer(operation, callback || block)
    end
  end
end
