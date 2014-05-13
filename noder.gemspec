require File.expand_path('../lib/noder/version', __FILE__)

Gem::Specification.new do |s|
  s.authors       = ['Tom Benner']
  s.email         = ['tombenner@gmail.com']
  s.description = s.summary = %q{Node.js for Ruby}
  s.homepage      = 'https://github.com/tombenner/noder'

  s.files         = Dir['lib/**/*'] + ['MIT-LICENSE', 'README.md']
  s.name          = 'noder'
  s.require_paths = ['lib']
  s.version       = Noder::VERSION
  s.license       = 'MIT'

  s.add_dependency 'eventmachine'
  s.add_dependency 'eventmachine_httpserver'
  s.add_dependency 'em-synchrony', '>= 1.0.0'

  s.add_development_dependency 'rspec'
end
