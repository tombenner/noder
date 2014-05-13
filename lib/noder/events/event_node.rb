module Noder
  module Events
    class EventNode
      attr_accessor :callback, :next_node

      def initialize(options={})
        @callback = options[:callback]
        @argument_keys = options[:argument_keys]
        @has_continued = false
        raise 'No callback provided' if @callback.nil?
      end

      def call(env)
        @env = env
        if @argument_keys
          arguments = Utils.slice_hash(@env, @argument_keys).values
        else
          arguments = [@env]
        end
        perform_callback(arguments)
        continue unless @has_continued
      end

      def continue(env=nil)
        @has_continued = true
        next_node.call(env || @env) if next_node
      end

      protected

      def perform_callback(arguments)
        continue_method = method(:continue)
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
