require 'em-synchrony'

module Noder
  module HTTP
    class Server
      include Events::EventEmitter

      attr_accessor :options

      def initialize(options={}, &block)
        defaults = {
          address: '0.0.0.0',
          port: 8000,
          app: nil,
          environment: 'development',
          threadpool_size: 20,
          enable_ssl: false,
          ssl_key: nil,
          ssl_cert: nil
        }
        @options = defaults.merge(options)
        # The 'close' event is emitted as EM is stopped, so we need to handle the callbacks outside of
        # the EM event loop with Events::EventNode instead of Events::EMEventNode
        set_node_class_for_event(Events::EventNode, 'close')
        push_default_callbacks
        on('request', &block) if block
      end

      def listen(port=nil, address=nil, options={}, &block)
        @options.merge!(options)
        @options[:port] = port if port
        @options[:address] = address if address
        EM.threadpool_size = @options[:threadpool_size]
        EM.epoll
        EM.synchrony do
          trap('INT')  { close }
          trap('TERM') { close }
          # Listeners::NotFound should run after all other listeners, so we'll add it here
          add_listener('request', Listeners::NotFound)

          Noder.logger.info "Running Noder at #{@options[:address]}:#{@options[:port]}..."
          emit('start')
          connection_settings = Noder::Utils.slice_hash(@options, [:enable_ssl, :ssl_key, :ssl_cert])
          EM.start_server(@options[:address], @options[:port], Noder::HTTP::Connection, block, connection_settings) do |connection|
            connection.request_stack = event_stack('request')
            connection.app = @options[:app]
            connection.environment = @options[:environment]
          end
        end
      end

      def on(event, callback=nil, &block)
        callback ||= block
        case event
        when 'request'
          super('request', callback, argument_keys: [:request, :response])
        when 'close'
          super('close', callback)
        else
          super(event, callback)
        end
      end

      def close
        Noder.logger.info 'Stopping Noder...'
        emit('close')
        EM.stop
      end

      protected

      def push_default_callbacks
        default_callbacks.each do |event, items|
          items.each do |item|
            add_listener(event, item)
          end
        end
      end

      def default_callbacks
        {
          'close' => [],
          'request' => [
            Listeners::Request,
            Listeners::Response
          ]
        }
      end
    end
  end
end
