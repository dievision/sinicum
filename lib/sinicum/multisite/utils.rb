module Sinicum
  module Multisite
    class Utils
      def self.all_root_paths
        if Rails.application.config.x.multisite_disabled == true
          []
        else
          Sinicum::Cache::ThreadLocalCache.fetch("multisite_nodes") do
            nodes = Sinicum::Jcr::Node.query(:multisite, :sql, "select * from mgnl:multisite")
            paths = nodes.collect{ |node| node[:root_node] }
            paths.select do |path|
              !localized_content_enabled? || valid_localized_content_prefix_path?(path)
            end
          end
        end
      end

      def self.root_node_for_host(host)
        if Rails.application.config.x.multisite_disabled == true
          ""
        else
          Sinicum::Cache::ThreadLocalCache.fetch("multisite_nodes_#{host}") do
            node = Sinicum::Jcr::Node.query(:multisite, :sql,
              "select * from mgnl:multisite where primary_domain like '%#{host}%'").first
            node[:root_node] if node
          end
        end
      end

      private

      def self.localized_content_enabled?
        headers = Thread.current["__sinicum_additional_headers"]
        if !headers
          return false
        end

        headers.respond_to?(:"[]") && headers[:sinicumLocalizedContentApi] == 1
      end

      def self.valid_localized_content_prefix_path?(path)
        path.index("/b2c/countries") == 0 || path.index("/b2c/languages") == 0
      end
    end
  end
end


module ActionDispatch
  module Http
    module URL
      class << self
        unless method_defined?(:sincum_path_for)
          alias_method :sincum_path_for, :path_for
        end

        # The path helpers are modified by this
        def path_for(options = nil)
          if options.is_a?(Hash) && options[:host]
            regexp = %r(^#{Sinicum::Multisite::Utils.root_node_for_host(options[:host])}(/|$))
          else
            regexp = %r(^(#{Sinicum::Multisite::Utils.all_root_paths.join("|")})(/|$))
          end
          sincum_path_for(options).sub(regexp, '/')
        end
      end
    end
  end

  module Routing
    module UrlFor
      unless method_defined?(:sincum_routing_url_for)
        alias_method :sincum_routing_url_for, :url_for
      end

      # The url_for in the controller context is modified by this
      def url_for(options = nil)
        if options.is_a?(Hash) && options[:host]
          regexp = %r(^#{Sinicum::Multisite::Utils.root_node_for_host(options[:host])}(/|$))
        else
          regexp = %r(^(#{Sinicum::Multisite::Utils.all_root_paths.join("|")})(/|$))
        end
        puts "#" * 80
        puts Sinicum::Multisite::Utils.all_root_paths.inspect
        puts "#" * 80
        sincum_routing_url_for(options).sub(regexp, '/')
      end
    end
  end
end

module ActionView
  module RoutingUrlFor
    unless method_defined?(:sincum_url_for)
      alias_method :sincum_url_for, :url_for
    end

    # The url_for in the view context is modified by this
    def url_for(options = nil)
      if options.is_a?(Hash) && options[:host]
        regexp = %r(^#{Sinicum::Multisite::Utils.root_node_for_host(options[:host])}(/|$))
      else
        regexp = %r(^(#{Sinicum::Multisite::Utils.all_root_paths.join("|")})(/|$))
      end
      sincum_url_for(options).sub(regexp, '/')
    end
  end
end
