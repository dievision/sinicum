module Sinicum
  module Cache
    class ThreadLocalCacheMiddleware
      def initialize(app)
        @app = app
      end

      def call(env)
        Sinicum::Cache::ThreadLocalCache.enable!
        begin
          status, headers, response = @app.call(env)
        ensure
          Sinicum::Cache::ThreadLocalCache.disable!
        end
        [status, headers, response]
      end
    end
  end
end
