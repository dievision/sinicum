module Sinicum
  module Jcr
    module Cache
      # Public: Fetches the global cache key from the JCR server.
      class GlobalCache
        API_PATH = "/_cache/global"
        JSON_CACHE_KEY = "cacheKey"
        include ::Sinicum::Jcr::ApiClient

        def current_key
          result = nil
          response = api_get(API_PATH)
          if response.ok?
            begin
              json = MultiJson.load(response.body)
              result = json[JSON_CACHE_KEY]
            rescue => e
              Rails.logger.error("Cannot load global cache key: " + e.message)
            end
          end
          result
        end
      end
    end
  end
end
