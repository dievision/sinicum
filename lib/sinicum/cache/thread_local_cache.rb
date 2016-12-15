module Sinicum
  module Cache
    class ThreadLocalCache
      THREAD_LOCAL_KEY = "#{name}-cache-key"
      THREAD_LOCAL_ACTIVATION_KEY = "#{THREAD_LOCAL_KEY}-activation"

      def self.put(key, value)
        cache[key] = value if active?
        value
      end

      def self.get(key)
        cache[key] if active?
      end

      def self.clear
        Thread.current[THREAD_LOCAL_KEY] = {}
      end

      def self.fetch(key, &block)
        if active? && cache.has_key?(key) && !get(key).nil?
          get(key)
        else
          result = block.call
          put(key, result)
          result
        end
      end

      def self.active?
        Thread.current[THREAD_LOCAL_ACTIVATION_KEY] == true
      end

      def self.enable!
        Thread.current[THREAD_LOCAL_ACTIVATION_KEY] = true
      end

      def self.disable!
        Thread.current[THREAD_LOCAL_ACTIVATION_KEY] = false
        clear
        nil
      end

      private

      def self.cache
        cache = Thread.current[THREAD_LOCAL_KEY]
        unless cache
          cache = {}
          Thread.current[THREAD_LOCAL_KEY] = cache
        end
        cache
      end
    end
  end
end
