Noder
=====
Node.js for Ruby

Overview
--------

Noder brings the architecture of Node.js to Ruby. It focuses on the implementation of Node.js's HTTP-related support, as Ruby's standard library and other gems already provide great analogs of many of Node.js's other core modules.

You may also be interested in [Expressr](https://github.com/tombenner/expressr) (Express.js for Ruby), which Noder was built to support, and [EM-Synchrony](https://github.com/igrigorik/em-synchrony). Noder runs on [EventMachine](https://github.com/eventmachine/eventmachine).

Example
-------

A web server can be created and started using the following script:

```ruby
require 'noder'

server = Noder::HTTP::Server.new do |request, response|
  response.write_head(200, { 'Content-Type' => 'text/plain' })
  response.end('Hello world!')
end
server.listen(1337, '127.0.0.1')
```

To start the app, put the code into a file named `my_server.rb` and run it:

```bash
$ ruby my_server.rb
Running Noder at 127.0.0.1:1337...
```

API
---

* [HTTP](#http)
  * [Server](#noderhttpserver)
  * [Request](#noderhttprequest)
  * [Response](#noderhttpresponse)
* [Events](#events)
  * [EventEmitter](#nodereventseventemitter)

HTTP
----

### Noder::HTTP::Server

`Noder::HTTP::Server` lets you create and run HTTP servers.

#### .new(options={}, &block)

Creates the server.

##### options

* `:address` - The server's address (default: `'0.0.0.0'`)
* `:port` - The server's port (default: `8000`)
* `:environment` - The server's environment name (default: `'development'`)
* `:threadpool_size` - The size of the server's threadpool default: `20`)
* `:enable_ssl` - A boolean of whether SSL is enabled (default: `false`)
* `:ssl_key` - A filepath to the SSL key (default: `nil`)
* `:ssl_cert` - A filepath to the SSL cert (default: `nil`)

##### &block

A block that will be called for every request. It will be passed the request (a Noder::HTTP::Request) and response (a Noder::HTTP::Response) as arguments.

#### #listen(port=nil, address=nil, options={}, &block)

Starts accepting connections to the server. `options` are the same as the options in `.new`, and `&block` behaves the same as in `.new`.

```ruby
server = Noder::HTTP::Server.new
server.listen(8001) do |request, response|
  response.write("Hello world!")
  response.end
end
```

#### #close

Stops the server. This is called when an `INT` or `TERM` signal is sent to a running server's process (e.g. when `Control-C` is pressed).

#### Event 'request'

Emitted for every request. The request and response are passed as arguments.

```ruby
server.on('request') do |request, response|
  Noder.logger.info "Request params: #{request.params}"
  response.set_header('MyHeader', 'My value')
end
```

#### Event 'close'

Emitted when the server is closing. No arguments are passed.

```ruby
server.on('close') do
  Noder.logger.info "Stopping server..."
end
```

### Noder::HTTP::Request

A representation of an HTTP request.

#### #params

A hash of the request's params (the query string and POST data). The hash's keys are strings (e.g. `/?foo=bar` yields `{ 'foo' => 'bar' }`)

#### #headers

A hash of the request's headers (e.g. `{ 'Accept' => '*/*', 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_5) [...]' }`).

#### #request_method

The request's verb (e.g. `'GET'`, `'POST'`, etc).

#### #cookie

The request's Cookie header (e.g. `'my_cookie=123; my_other_cookie=foo'`).

#### #content_type

The request's Content-Type header (e.g. `'application/x-www-form-urlencoded'`).

#### #request_uri

The request's path, without the query string (e.g. `'/users/1/profile'`).

#### #query_string

The request's query string (e.g. `/about?foo=bar&baz=1` yields `'foo=bar&baz=1'`).

#### #protocol

The request's protocol (e.g. `'HTTP/1.1'`).

#### #ip

The client's IP address (e.g. `'68.1.8.45'`).

### Noder::HTTP::Response

A representation of an HTTP response.

#### #write(content)

Writes the content to the response's body.

```ruby
response.write('Hello world!')
```

#### #write_head(status, headers={})

Sets the response's status code and sets the specified headers (if any).

```ruby
response.write_head(500, { 'MyHeader' => 'My value' })
```

#### #status_code

Gets or sets the response's status code

```ruby
response.status_code # 200
response.status_code = 500
```

#### #set_header(name, value)

Sets the specified header.

```ruby
response.set_header('MyHeader', 'My value')
```

#### #get_header(name, value)

Gets the specified header.

```ruby
response.get_header('MyHeader') # 'My value'
```

#### #remove_header(name)

Gets the specified header.

```ruby
response.remove_header('MyHeader')
```

#### #end(content=nil)

Sends the response. This must be called on every response instance.

If `content` is provided, it is equivalent to calling `write(content)` followed by `end`.

Events
------

### Noder::Events::EventEmitter

Include `Noder::Events::EventEmitter` in classes which should manage events. For example:

```ruby
class MyServer
  include Noder::Events::EventEmitter

  def initialize(&block)
    on('start', &block)
    on('stop', proc { puts 'Stopping...' })
  end

  def run
    emit('start')
    emit('stop')
  end
end

server = MyServer.new do
  puts 'Starting up...'
end
server.on('start') do
  puts 'Still starting up...'
end

server.run
# Starting up...
# Still starting up...
# Stopping...
```

#### #on(event, callback=nil, options={}, &block)

Adds a listener to the specified event. The listener can either be an instance of a Proc (as the `callback` argument) or a block.

`add_listener` is an alias of `on`.

#### #emit(event)

Call the listeners for the specified event.

#### #remove_listener(event, listener)

Remove the listener. Listeners are compared using the `==` operator.

```ruby
listener = proc { puts 'Working...' }
server.on('start', listener)
server.remove_listener('start', listener)
```

#### #remove_all_listeners(event)

Removes all of the listeners from the event. You probably don't want to call this on core Noder events.

```ruby
server.remove_all_listeners('start')
```

#### #set_max_listeners(event, count)

Sets the maximum number of listeners for the specified event. A warning will be logged every time any additional listeners are added.

```ruby
server.set_max_listeners('start', 100)
```

#### #listeners(event)

Returns an array of the listeners for the specified event.

```ruby
server.listeners('start')
```

#### #listener_count(event)

Returns the number of listeners for the specified event.

```ruby
server.listener_count('start')
```

Logging
-------

Noder's `Logger` is available at `Noder.logger`. You can write to it:

```ruby
Noder.logger.debug 'My debug message...'
Noder.logger.error 'My error message...'
```

You can modify it or replace it if you like, too:

```ruby
# Adjust attributes of the logger
Noder.logger.level = Logger::DEBUG

# Or create a custom Logger
Noder.logger = Logger.new(STDOUT)
Noder.logger.level = Logger::DEBUG
```

See the [Logger docs](http://www.ruby-doc.org/stdlib-2.0/libdoc/logger/rdoc/Logger.html) for more.

HTTPS
-----

To support HTTPS, set `:enable_ssl` to `true` and set the `:ssl_key` and `:ssl_cert` values to the appropriate file paths:

```ruby
options = {
  enable_ssl: true,
  ssl_key: File.expand_path('../certs/key.pem', __FILE__),
  ssl_cert: File.expand_path('../certs/cert.pem', __FILE__)
}
server = Noder::HTTP::Server.new(options)
```

Notes
-----

Noder is not currently a full implementation of Node.js, and some of its underlying architecture differs from Node.js's. If you see any places where it could be improved or added to, absolutely feel free to submit a PR.

License
-------

Noder is released under the MIT License. Please see the MIT-LICENSE file for details.
