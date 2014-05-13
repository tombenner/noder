directory = File.dirname(File.absolute_path(__FILE__))
Dir.glob("#{directory}/events/**/*.rb") { |file| require file }

module Noder
  module Events
  end
end
