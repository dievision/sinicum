require 'yaml'

module Sinicum
  # Internal: Initialize the Gem in a Rails environment
  class Engine < Rails::Engine
    initializer "configure_jcr" do |app|
      config_file = File.join(Rails.root,
        ::Sinicum::Jcr::ConfigurationReader::SINICUM_SERVER_CONFIG_FILE)
      config = ::Sinicum::Jcr::ConfigurationReader.read_from_file(config_file)

      ::Sinicum::Jcr::ApiQueries.configure_jcr = config
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
            /#{Regexp.quote(Rails.configuration.assets.prefix)}/
        else
          app.config.x.multisite_ignored_paths =
            [/#{Regexp.quote(Rails.configuration.assets.prefix)}/]
        end
      end
    end
  end
end
