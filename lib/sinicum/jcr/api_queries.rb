require 'httpclient'

module Sinicum
  module Jcr
    # Private: Encapsulates the functionality to run queries on the server.
    class ApiQueries
      @@http_client_mutex = Mutex.new
      class << self
        attr_reader :jcr_configuration

        def configure_jcr=(config_hash)
          @http_client = nil
          if config_hash
            @jcr_configuration = JcrConfiguration.new(config_hash.dup.with_indifferent_access)
            if @jcr_configuration.username.present? || @jcr_configuration.password.present?
              http_client.set_auth(nil, @jcr_configuration.username, @jcr_configuration.password)
              http_client.www_auth.basic_auth.challenge(@jcr_configuration.base_proto_host_port)
            end
            if @jcr_configuration.protocol == "https"
              http_client.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE
            end
          end
        end

        def http_client
          # Thread Safety?
          return @http_client if @http_client
          @@http_client_mutex.synchronize do
            return @http_client if @http_client
            @http_client ||= HTTPClient.new
          end
          @http_client
        end
      end
    end
  end
end
