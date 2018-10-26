module Sinicum
  module Jcr
    module ApiClient
      include ::Sinicum::Logger
      def api_get(path, args = nil, &block)
        full_path = api_full_path(URI.escape(path))
        log_get_path(full_path, args)

        instrumentation_query = args && args["query"] ? args["query"] : path

        ActiveSupport::Notifications.instrument(
          "jcr_query.sinicum",
          query: instrumentation_query,
          context: "Sinicum API GET:") do
          start = Time.now
          result = ApiQueries.http_client.get(full_path, args, additional_headers, &block)
          elapsed_time = ((Time.now - start).to_f * 1000).round(1)
          logger.debug("      Completed request in #{elapsed_time}ms")
          result
        end
      end

      def api_post(path, *args, &block)
        full_path = api_full_path(path)
        log = "    Sinicum API POST: " + full_path
        [:body, :query].each do |key|
          if args[0] && args[0].respond_to?(:[]) && args[0][key]
            log << "\n      Parameters (#{key.to_s.capitalize}): " + args[0][key].inspect
          end
        end
        logger.debug(log)
        ApiQueries.http_client.post(full_path, *args, &block)
      end

      private
      def additional_headers
        if Thread.current["__sinicum_additional_headers"] &&
          Thread.current["__sinicum_additional_headers"].is_a?(Hash)
          Thread.current["__sinicum_additional_headers"]
        else
          {}
        end
      end

      def log_get_path(full_path, args)
        log = "    Sinicum API GET: Ω" + full_path
        if args && args.respond_to?(:[])
          log << "\n      Parameters (Query): " + args.inspect
        end
        logger.debug(log)
      end

      def api_full_path(path)
        ApiQueries.jcr_configuration.base_url + path
      end
    end
  end
end
