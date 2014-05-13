module Noder
  module Events
    class EventStack
      extend Forwardable

      attr_reader :items

      def_delegators :@items, :length

      def initialize(options={})
        @items = []
        @node_class = options[:node_class] || EMEventNode
      end

      def push(options={})
        @items << options
      end

      def insert_before(target_callback, item)
        index = index_of_callback(target_callback)
        raise "Item not found for callback: #{target_callback}" if index.nil?
        @items.insert(index, item)
      end

      def replace(target_callback, item)
        index = index_of_callback(target_callback)
        raise "Item not found for callback: #{target_callback}" if index.nil?
        @items[index] = item
      end

      def remove(target_callback)
        index = index_of_callback(target_callback)
        @items.delete_at(index) if index
      end

      def remove_all
        @items = []
      end

      def index_of_callback(callback)
        @items.index { |item| item[:callback] == callback }
      end

      def call(env=nil)
        empty_node = @node_class.new({ callback: proc { |env| env } })
        nodes = @items.map { |item| @node_class.new(item) }
        first_node = nodes.reverse.inject(empty_node) do |next_node, current_node|
          current_node.next_node = next_node
          current_node
        end
        first_node.call(env)
      end

      protected

      def does_item_match?(item, env)
        callback = item[:callback]
        return true unless callback.respond_to?(:matches_env?)
        callback.matches_env?(env)
      end
    end
  end
end
