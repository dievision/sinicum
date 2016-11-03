module Sinicum
  module Multisite
    class Utils
      def self.all_root_paths
        if Rails.application.config.x.multisite_disabled == true
          []
        else
          Sinicum::Cache::ThreadLocalCache.fetch("multisite_nodes") do
            nodes = Sinicum::Jcr::Node.query(:multisite, :sql, "select * from mgnl:multisite")
            nodes.collect{ |node| node[:root_node] }
          end
        end
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
          regexp = %r(^(#{Sinicum::Multisite::Utils.all_root_paths.join("|")})(/|$))
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
        regexp = %r(^(#{Sinicum::Multisite::Utils.all_root_paths.join("|")})(/|$))
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
      regexp = %r(^(#{Sinicum::Multisite::Utils.all_root_paths.join("|")})(/|$))
      sincum_url_for(options).sub(regexp, '/')
    end
  end
end
