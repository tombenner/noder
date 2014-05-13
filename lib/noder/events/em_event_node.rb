module Noder
  module Events
    class EMEventNode
      attr_accessor :callback, :next_node

      def initialize(options={})
        @callback = options[:callback]
        @argument_keys = options[:argument_keys]
        raise 'No callback provided' if @callback.nil?
      end

      def call(env)
        if callback.respond_to?(:matches_env?) && !callback.matches_env?(env)
          if next_node
            operation = proc { next_node.call(env) }
            EM.defer(operation)
          end
          return
        end
        operation = proc { call_operation(env) }
        if next_node
          callback = proc { |env| next_node.call(env) }
          EM.defer(operation, callback)
        else
          EM.defer(operation)
        end
        env
      end

      protected

      def call_operation(env)
        @env = env
        if @argument_keys
          arguments = Utils.slice_hash(@env, @argument_keys).values
        else
          arguments = [@env]
        end
        perform_callback(arguments)
        @env
      end

      def perform_callback(arguments)
        continue_method = proc { EM.signal_loopbreak }
        if @callback.is_a?(Proc)
          @callback.call(*arguments, continue_method)
        elsif @callback.is_a?(Class)
          @env = @callback.new(continue_method).call(*arguments)
        else
          @env = @callback.call(*arguments, continue_method)
        end
      end
    end
  end
end
