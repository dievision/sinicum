module Sinicum
  module Controllers
    # Public: Filter to cache the result of a page if no changes in Magnolia
    # occured.
    class GlobalStateCache
      DEPLOY_REVISION_FILE = "REVISION"
      THREAD_LOCAL_VAR_NAME = "__sinicum_global_state_cache"

      def initialize(controller)
        @controller = controller
        @global_jcr_cache_key = Sinicum::Jcr::Cache::GlobalCache.new.current_key(cache_namespace)
      end

      def self.before(controller)
        if do_cache?
          instance = new(controller)
          Thread.current[THREAD_LOCAL_VAR_NAME] = instance
          instance.render_or_proceed
        end
      end

      def self.after(controller)
        if do_cache?
          begin
            instance = Thread.current[THREAD_LOCAL_VAR_NAME]
            instance.cache_response if instance
          ensure
            Thread.current[THREAD_LOCAL_VAR_NAME] = nil
          end
        end
      end

      def render_or_proceed
        cached = Rails.cache.fetch(cache_key)
        if cached && cached[:status].to_s == "200"
          @controller.response.cache_control.merge!(cached[:cache_control])
          @controller.response.status = cached[:status]
          @controller.response.headers["X-SCache"] = "true"
          @controller.original_rails_render html: cached[:body].html_safe
        else
          @controller.response.headers["X-SCache"] = "false"
        end
      end

      def cache_response
        response = @controller.response
        if @controller.request.get? && response.cache_control[:public] &&
            response.cache_control[:max_age] && response.cache_control[:max_age] > 0
          cache_content = {
            body: response.body,
            cache_control: response.cache_control,
            status: response.status
          }
          cache_options = {}
          if @controller.respond_to?(:global_state_cache_expiration_time)
            cache_options = { expires_in: @controller.global_state_cache_expiration_time }
          end
          Rails.cache.write(cache_key, cache_content, cache_options)
        end
      end

      private

      def cache_key
        @cache_key ||= [
          @controller.request.base_url + @controller.request.fullpath,
          @global_jcr_cache_key, self.class.deploy_revision
        ]
        @cache_key
      end

      def self.deploy_revision
        unless @deploy_revision
          revision_file = File.join(Rails.root, DEPLOY_REVISION_FILE)
          if File.exist?(revision_file)
            @deploy_revision = File.read(revision_file).chomp
          end
        end
        @deploy_revision
      end

      def self.do_cache?
        Rails.application.config.action_controller.perform_caching
      end

      def cache_namespace
        if Rails.configuration.x.multisite_production
          @controller.request.host
        else
          nil
        end
      end
    end
  end
end
