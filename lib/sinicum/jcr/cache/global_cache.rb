module Sinicum
  module Jcr
    module Cache
      # Public: Fetches the global cache key from the JCR server.
      class GlobalCache
        CACHE_KEY = "sinicum_global_cache"
        MAX_NAMESPACE_SIZE = 4096

        def current_key(namespace = nil)
          keys = Rails.cache.fetch_multi(key_name(nil), key_name(namespace)) do
            create_key
          end
          Digest::SHA1.hexdigest(keys.values.join("-"))
        end

        def reset_key(namespace = nil)
          Rails.cache.write(key_name(namespace), create_key)
        end

        private

        def create_key
          SecureRandom.hex
        end

        def key_name(namespace)
          if namespace && namespace.length > MAX_NAMESPACE_SIZE
            raise ArgumentError.new("Cache namespace too long")
          end
          [CACHE_KEY, namespace && Digest::SHA1.hexdigest(namespace)].join("-")
        end
      end
    end
  end
end
