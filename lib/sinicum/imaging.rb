module Sinicum
  module Imaging
    DEFAULT_CONVERTER_NAME = "default"

    def self.default_converter_name
      DEFAULT_CONVERTER_NAME
    end

    def self.on_imaging_path?(path)
      app_from_path(path) ? true : false
    end

    def self.app_from_path(path)
      if path
        Config.read_configuration.apps.each do |app_name, app_details|
          return app_details if path.start_with?(app_details['imaging_prefix'], app_details['magnolia_prefix'])
        end
      end
      return nil
    end

    def self.app_from_workspace(workspace)
      if workspace
        Config.read_configuration.apps.each do |app_name, app_details|
          return app_details if app_details['workspace'] == workspace
        end
      end
      return nil
    end
  end
end
