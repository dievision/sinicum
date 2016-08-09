module Sinicum
  module Multisite
    class MultisiteMiddleware

      def initialize(app)
        @app = app      
      end

      def call(env)
        request = Rack::Request.new(env)
        path = request.path
        unless rails_path?(env)
          if Rails.configuration.x.multisite_production == true
            node = node_from_primary_domain(request.host)
            if node.nil?
              node = node_from_alias_domains(request.host)
              return redirect("#{node[:primary_domain]}#{request.fullpath}") if node
            else
              env['rack.session'][:multisite_root] = node[:root_node]
            end
          else # author/dev
            query = "select * from mgnl:multisite where root_node LIKE '#{root_from_path(path)}'"
            nodes = Sinicum::Jcr::Node.query(:multisite, :sql, query)
            if nodes.empty?
              if env['rack.session'][:multisite_root].nil?
                query = "select * from mgnl:page where jcr:path LIKE '/%#{path}'"
                website_nodes = Sinicum::Jcr::Node.query(:website, :sql, query)
                website_node = website_nodes.select{ |x| x.path =~ /^\/[a-z]*?#{path}$/ }.first
                if website_node
                  query = "select * from mgnl:multisite where root_node LIKE '#{root_from_path(website_node.path)}'"
                  node = Sinicum::Jcr::Node.query(:multisite, :sql, query).first
                  env['rack.session'][:multisite_root] = node[:root_node]
                end
              end
            else
              node = nodes.first
              env['rack.session'][:multisite_root] = node[:root_node]
            end
          end
        end
        status, headers, response = @app.call(adjust_paths(env, env['rack.session'][:multisite_root]))
        [status, headers, response]
      end

      private
      def node_from_alias_domains(domain)
        query = "select * from mgnl:multisite where alias_domains LIKE '%//#{domain}%'"
        Sinicum::Jcr::Node.query(:multisite, :sql, query).first
      end

      def node_from_primary_domain(domain)
        query = "select * from mgnl:multisite where primary_domain LIKE '%//#{domain}%'"
        Sinicum::Jcr::Node.query(:multisite, :sql, query).first
      end

      def adjust_paths(env, root_path)
        return env if rails_path?(env) || root_path.nil? || env['PATH_INFO'].start_with?(root_path)
        %w(REQUEST_PATH PATH_INFO REQUEST_URI ORIGINAL_FULLPATH).each do |env_path|
          env[env_path] = "#{root_path}#{env['PATH_INFO']}"
        end
        env
      end

      def root_from_path(path)
        path.gsub(/(^\/.*?)\/.*/, '\1').gsub(".html", "")
      end

      def rails_path?(env)
        %w(assets)
          .collect{ |x| env['PATH_INFO'].start_with?("/#{x}") }
          .include?(true)
      end

      def redirect(location)
        [301, { 'Location' => location, 'Content-Type' => 'text/html' }, ['Moved Permanently']]
      end
    end
  end
end
