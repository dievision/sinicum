module Sinicum
  module Jcr
    # Public: Handles the configuration for accessing the JCR server.
    class JcrConfiguration
      attr_accessor :host, :protocol, :path_prefix, :username, :password
      DEFAULT_HOST = "localhost"
      DEFAULT_PORT = "8080"
      DEFAULT_PROTOCOL = "http"
      DEFAULT_PREFIX = "/sinicum-rest"

      def initialize(params = {})
        [:host, :port, :protocol, :path_prefix, :username, :password].each do |param|
          send("#{param}=", params[param]) if params.key?(param)
        end
      end

      def path_prefix=(path_prefix)
        path_prefix = "/" + path_prefix if path_prefix.size > 0 && path_prefix[0] != "/"
        @path_prefix = path_prefix
      end

      def port=(port)
        @port = port.to_s
      end

      def port
        port = @port
        unless port
          if protocol == "http"
            port = "80"
          elsif protocol == "https"
            port = "443"
          else
            port = ""
          end
        end
        port
      end

      def protocol
        @protocol || DEFAULT_PROTOCOL
      end

      def base_url
        unless defined?(@base_url)
          base_url = base_proto_host_port.dup
          base_url << (path_prefix || DEFAULT_PREFIX)
          @base_url = base_url
        end
        @base_url
      end

      def base_proto_host_port
        unless defined?(@base_proto_host_port)
          base_proto_host_port = protocol.dup
          base_proto_host_port << "://"
          base_proto_host_port << (host || DEFAULT_HOST)
          unless (port.to_i == 80 && protocol == "http") || port.to_i == 443 && protocol == "https"
            base_proto_host_port << ":" << port
          end
          @base_proto_host_port = base_proto_host_port
        end
        @base_proto_host_port
      end
    end
  end
end
