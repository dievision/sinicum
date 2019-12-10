module Sinicum
  module Multisite
    class MultisiteMiddleware
      def initialize(app)
        @app = app
      end

      def call(env)
        request = ActionDispatch::Request.new(env)
        @path = request.path.gsub(".html", "")
        unless multisite_ignored_path?(env)
          if Rails.configuration.x.multisite_production == true
            node = node_from_domain(request.host, :primary_domain)
            if node.nil?
              # Alias domain handling - redirect to the primary domain
              node = node_from_domain(request.host, :alias_domains)
              return redirect("#{node[:primary_domain]}#{request.fullpath}") if node
            else
              request.session[:multisite_root] = node[:root_node]
            end
          else # author/dev
            query = "select * from mgnl:multisite where root_node LIKE '/#{splitted_path[1]}'"
            if splitted_path.size > 2
              query += " OR root_node LIKE '/#{splitted_path[1]}/#{splitted_path[2]}'"
            end
            if node = Sinicum::Jcr::Node.query(:multisite, :sql, query).first
              unless request.session[:multisite_root] == "/b2c/countries" &&
                  (node[:root_node] == "/en-GB" || node[:root_node] == "/de-DE" ||
                    node[:root_node] == "/nl-NL")
                log("Node has been found - Session => #{node[:root_node].inspect}")
                request.session[:multisite_root] = node[:root_node]
              end
            end
            if on_root_path?(request.session[:multisite_root], request.fullpath)
              # Redirect to the fullpath without the root_path for consistency
              return redirect(gsub_root_path(
                request.session[:multisite_root], request.fullpath))
            end
          end
        end
        status, headers, response =
          @app.call(adjust_paths(env, request.session[:multisite_root]))
        [status, headers, response]
      end

      private
      def log(msg)
        Rails.logger.info("  Sinicum Multisite:" + msg) if Rails.configuration.x.multisite_logging
      end

      def node_from_domain(domain, type)
        Rails.cache.fetch("sinicum-multisite-node-#{type}-#{domain}", expires: 1.hour) do
          query = "select * from mgnl:multisite where #{type} LIKE '%//#{domain}%'"
          Sinicum::Jcr::Node.query(:multisite, :sql, query).first
        end
      end

      def on_root_path?(root_path, path)
        !!(root_path && path.match(/^(#{root_path})\//))
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

      def splitted_path
        @path.split('/')
      end

      def multisite_ignored_path?(env)
        Rails.configuration.x.multisite_ignored_paths
          .collect{ |x| !!(x.match(env['PATH_INFO'])) }
          .include?(true)
      end

      def redirect(location)
        [307, { 'Location' => location, 'Content-Type' => 'text/html' }, ['Moved Permanently']]
      end
    end
  end
end
