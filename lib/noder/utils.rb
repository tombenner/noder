require 'uri'

module Noder
  module Utils
    def slice_hash(hash, keys)
      keys.each_with_object({}) { |k, new_hash| new_hash[k] = hash[k] if hash.has_key?(k) }
    end
    module_function :slice_hash
  end
end
