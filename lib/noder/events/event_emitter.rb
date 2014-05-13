module Noder
  module Events
    module EventEmitter
      def event_stacks
        @event_stacks ||= {}
      end

      def max_listener_counts
        @max_listener_counts ||= {}
      end

      def on(event, callback=nil, options={}, &block)
        max_count = max_listener_counts[event]
        current_count = listener_count(event)
        if max_count && current_count >= max_count
          Noder.logger.warn "Maximum listener count exceeded for #{self.class} (max count is #{max_count}; current count is #{current_count})."
        end
        callback ||= block
        options[:callback] = callback
        event_stacks[event] ||= EventStack.new(node_class: node_class_for_event(event))
        event_stacks[event].push(options)
      end

      def emit(event, *arguments)
        return if event_stacks[event].nil?
        event_stacks[event].call(*arguments)
      end

      def remove_listener(event, listener)
        event_stacks[event].remove(listener)
      end

      def remove_all_listeners(event)
        event_stacks[event].remove_all
      end

      def set_max_listeners(event, count)
        max_listener_counts[event] = count
      end

      def listeners(event)
        if event_stacks[event]
          event_stacks[event].items.map { |item| item[:callback] }
        else
          []
        end
      end

      def listener_count(event)
        if event_stacks[event]
          event_stacks[event].length
        else
          0
        end
      end

      def event_stack(event)
        event_stacks[event]
      end

      alias_method :add_listener, :on

      protected

      def set_node_class_for_event(klass, event)
        event_node_classes[event] = klass
      end

      def event_node_classes
        @event_node_classes ||= {}
      end

      def node_class_for_event(event)
        event_node_classes[event] || EMEventNode
      end
    end
  end
end
