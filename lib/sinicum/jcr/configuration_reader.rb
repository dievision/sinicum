module Sinicum
  module Jcr
    module ConfigurationReader
      SINICUM_SERVER_CONFIG_FILE = File.join("config", "sinicum_server.yml")

      def self.read_from_file(filename)
        unless File.exist?(filename)
          Rails.logger.warn("Sinicum configuration file not found, Sinicum is not configured.")
          return
        end

        jcr_config_file = ERB.new(File.read(filename)).result
        config = YAML.load(jcr_config_file)[Rails.env]
        config
      end
    end
  end
end
