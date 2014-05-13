require 'uri'

module Noder
  module HTTP
    module Utils
      DEFAULT_SEP = /[&;] */n
      
      class << self
        attr_accessor :key_space_limit
      end

      # The default number of bytes to allow parameter keys to take up.
      # This helps prevent a rogue client from flooding a Request.
      self.key_space_limit = 65536

      class KeySpaceConstrainedParams
        def initialize(limit = Utils.key_space_limit)
          @limit  = limit
          @size   = 0
          @params = {}
        end

        def [](key)
          @params[key]
        end

        def []=(key, value)
          @size += key.size if key && !@params.key?(key)
          raise RangeError, 'exceeded available parameter key space' if @size > @limit
          @params[key] = value
        end

        def key?(key)
          @params.key?(key)
        end

        def to_params_hash
          hash = @params
          hash.keys.each do |key|
            value = hash[key]
            if value.kind_of?(self.class)
              hash[key] = value.to_params_hash
            elsif value.kind_of?(Array)
              value.map! {|x| x.kind_of?(self.class) ? x.to_params_hash : x}
            end
          end
          hash
        end
      end

      if defined?(::Encoding)
        def unescape(s, encoding = Encoding::UTF_8)
          URI.decode_www_form_component(s, encoding)
        end
      else
        def unescape(s, encoding = nil)
          URI.decode_www_form_component(s, encoding)
        end
      end
      module_function :unescape

      def parse(qs, d = nil, &unescaper)
        unescaper ||= method(:unescape)

        params = KeySpaceConstrainedParams.new

        (qs || '').split(d ? /[#{d}] */n : DEFAULT_SEP).each do |p|
          next if p.empty?
          k, v = p.split('=', 2).map(&unescaper)

          if cur = params[k]
            if cur.class == Array
              params[k] << v
            else
              params[k] = [cur, v]
            end
          else
            params[k] = v
          end
        end

        return params.to_params_hash
      end
      module_function :parse

      def parse_headers(string)
        string.split("\x00").reduce({}) do |hash, string|
          key, value = string.split(': ', 2)
          hash[key] = value
          hash
        end
      end
      module_function :parse_headers
    end
  end
end
