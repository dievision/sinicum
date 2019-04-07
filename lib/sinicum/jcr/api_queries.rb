require 'httpclient'

module Sinicum
  module Jcr
    # Private: Encapsulates the functionality to run queries on the server.
    class ApiQueries
      class << self
        attr_reader :jcr_configuration

        def configure_jcr=(config_hash)
          if config_hash
            @jcr_configuration = JcrConfiguration.new(config_hash.dup.with_indifferent_access)
          end
          http_client_reset!
        end

        def http_client
          # Thread Safety?
          return @http_client if @http_client
          http_client_mutex.synchronize do
            return @http_client if @http_client
            @http_client = build_http_client
          end
          @http_client
        end

        def http_client_reset!
          http_client_mutex.synchronize do
            @http_client = nil
          end
        end

        private

        def http_client_mutex
          @http_client_mutex ||= Mutex.new
        end

        def build_http_client
          clnt = HTTPClient.new
          if @jcr_configuration &&
              (@jcr_configuration.username.present? || @jcr_configuration.password.present?)
            clnt.set_auth(nil, @jcr_configuration.username, @jcr_configuration.password)
            clnt.www_auth.basic_auth.challenge(@jcr_configuration.base_proto_host_port)
          end
          clnt
        end
      end
    end
  end
end
