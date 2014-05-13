directory = File.dirname(File.absolute_path(__FILE__))
Dir.glob("#{directory}/http/**/*.rb") { |file| require file }

module Noder
  module HTTP
  end
end
