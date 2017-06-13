module Sinicum
  module Jcr
    module Cache
      # Public: Fetches the global cache key from the JCR server.
      class SiteCache
        API_PATH = "/_cache/site"
        JSON_CACHE_KEY = "cacheKey"
        include ::Sinicum::Jcr::ApiClient

        def current_key_for(path)
          result = nil
          response = api_get("#{API_PATH}/#{site_prefix(path)}")
          if response.ok?
            begin
              json = MultiJson.load(response.body)
              result = json[JSON_CACHE_KEY]
            rescue => e
              Rails.logger.error("Cannot load site cache key: " + e.message)
            end
          end
          result
        end

        def site_prefix(path)
          path.split("/")[1]
        end
      end
    end
  end
end
