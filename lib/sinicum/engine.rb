require 'yaml'

module Sinicum
  # Internal: Initialize the Gem in a Rails environment
  class Engine < Rails::Engine
    SINICUM_SERVER_CONFIG_FILE = File.join("config", "sinicum_server.yml")

    initializer "configure_jcr" do |app|
      config_file = File.join(Rails.root, SINICUM_SERVER_CONFIG_FILE)
      if File.exist?(config_file)
        jcr_config_file = File.read(config_file)
        config = YAML.load(jcr_config_file)[Rails.env]
        ::Sinicum::Jcr::ApiQueries.configure_jcr = config
      else
        Rails.logger.warn("Sinicum configuration file not found, Sinicum is not configured.")
      end
    end

    initializer "sinicum.add_middleware" do |app|
      app.middleware.insert_after ActionDispatch::Callbacks,
        Sinicum::Cache::ThreadLocalCacheMiddleware
      app.middleware.insert_after Sinicum::Cache::ThreadLocalCacheMiddleware,
        Sinicum::Imaging::ImagingMiddleware
      unless app.config.x.multisite_disabled == true
        app.middleware.use Sinicum::Multisite::MultisiteMiddleware
        if app.config.x.multisite_ignored_paths.is_a?(Array)
          app.config.x.multisite_ignored_paths <<
            /#{Regexp.quote("/assets")}/
        else
          app.config.x.multisite_ignored_paths =
            [/#{Regexp.quote("/assets")}/]
        end
      end
    end
  end
end
