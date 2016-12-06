module Sinicum
  module Multisite
    class MultisiteMiddleware

      def initialize(app)
        @app = app
      end

      def call(env)
        request = Rack::Request.new(env)
        path = request.path.gsub(".html", "")
        unless multisite_ignored_path?(env)
          if Rails.configuration.x.multisite_production == true
            node = node_from_primary_domain(request.host)
            if node.nil?
              # Alias domain handling - redirect to the primary domain
              node = node_from_alias_domains(request.host)
              return redirect("#{node[:primary_domain]}#{request.fullpath}") if node
            else
              request.session[:multisite_root] = node[:root_node]
            end
          else # author/dev
            Rails.logger.info("    Sinicum Multisite: Session =>" \
              " #{request.session[:multisite_root].inspect}")
            if request.session[:multisite_root] &&
                on_root_path?(request.session[:multisite_root], request.fullpath)
              # Redirect to the fullpath without the root_path for consistency
              Rails.logger.info("    Sinicum Multisite: Redirect to the fullpath")
              return redirect(gsub_root_path(
                request.session[:multisite_root], request.fullpath))
            end
            query = "select * from mgnl:multisite where root_node LIKE '#{root_from_path(path)}'"
            nodes = Sinicum::Jcr::Node.query(:multisite, :sql, query)
            if nodes.empty?
              if request.session[:multisite_root].nil?
                # If the root node has not been found, it will check
                # for a matching child node of any root node. The first
                # one will be taken.
                query = "select * from mgnl:page where jcr:path LIKE '/%#{path}'"
                website_nodes = Sinicum::Jcr::Node.query(:website, :sql, query)
                website_node = website_nodes.select{ |x| x.path =~ /^\/[a-zA-Z_-]*?#{%r(path)}$/ }.first
                if website_node
                  query = "select * from mgnl:multisite where root_node " \
                    "LIKE '#{root_from_path(website_node.path)}'"
                  node = Sinicum::Jcr::Node.query(:multisite, :sql, query).first
                  Rails.logger.info("    Sinicum Multisite: SubNode has been found - Session =>" \
                    " #{node[:root_node].inspect}")
                  request.session[:multisite_root] = node[:root_node]
                end
              end
            else
              # Node has been found, so the session is set
              node = nodes.first
              Rails.logger.info("    Sinicum Multisite: Node has been found - Session =>" \
                " #{node[:root_node].inspect}")
              request.session[:multisite_root] = node[:root_node]
            end
          end
        end
        status, headers, response =
          @app.call(adjust_paths(env, request.session[:multisite_root]))
        [status, headers, response]
      end

      private
      def node_from_alias_domains(domain)
        Rails.cache.fetch("sinicum-multisite-node-alias-#{domain}", expires: 1.hour) do
          query = "select * from mgnl:multisite where alias_domains LIKE '%//#{domain}%'"
          Sinicum::Jcr::Node.query(:multisite, :sql, query).first
        end
      end

      def node_from_primary_domain(domain)
        Rails.cache.fetch("sinicum-multisite-node-primary-#{domain}", expires: 1.hour) do
          query = "select * from mgnl:multisite where primary_domain LIKE '%//#{domain}%'"
          Sinicum::Jcr::Node.query(:multisite, :sql, query).first
        end
      end

      def on_root_path?(root_path, path)
        path.match(/^(#{root_path})\//) if root_path
      end

      def gsub_root_path(root_path, path)
        clean_path = path.gsub(root_path, '')
        clean_path.empty? ? '/' : clean_path
      end

      def adjust_paths(env, root_path)
        return env if multisite_ignored_path?(env) || root_path.nil?
        return env if env['PATH_INFO'].start_with?(root_path) &&
          Rails.configuration.x.multisite_production != true
        %w(REQUEST_PATH PATH_INFO REQUEST_URI ORIGINAL_FULLPATH).each do |env_path|
          env[env_path] = "#{root_path}#{env['PATH_INFO']}"
        end
        env
      end

      def root_from_path(path)
        path.gsub(/(^\/.*?)\/.*/, '\1')
      end

      def multisite_ignored_path?(env)
        Rails.configuration.x.multisite_ignored_paths
          .collect{ |x| !!(x.match(env['PATH_INFO'])) }
          .include?(true)
      end

      def redirect(location)
        [301, { 'Location' => location, 'Content-Type' => 'text/html' }, ['Moved Permanently']]
      end
    end
  end
end
