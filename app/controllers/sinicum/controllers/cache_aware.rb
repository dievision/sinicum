module Sinicum
  module Controllers
    module CacheAware
      DEFAULT_CACHE_EXPIRATION_TIME = 10.minutes
      TIMESTAMP_ASSET_EXPIRATION_TIME = 30.days

      # Sets the HTTP cache parameters. By default, an expiration time of 10 minutes and a
      # public cache is used when `Rails.env` is `production`
      def client_cache_control
        if Rails.application.config.action_controller.perform_caching
          expires_in(DEFAULT_CACHE_EXPIRATION_TIME, public: true)
        end
      end
    end
  end
end
