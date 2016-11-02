module Sinicum
  module Multisite
    class Utils
      def self.all_root_paths
        nodes = Sinicum::Jcr::Node.query(:multisite, :sql, "select * from mgnl:multisite'")
        nodes.collect{ |node| node[:root_node] }
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

        def path_for(options = nil)
          regexp = %r(^(#{Sinicum::Multisite::Utils.all_root_paths.join("|")})(/|$))
          sincum_path_for(options).sub(regexp, '/')
        end
      end
    end
  end

  module Routing
    module UrlFor
      unless method_defined?(:sincum_url_for)
        alias_method :sincum_url_for, :url_for
      end

      def url_for(options = nil)
        regexp = %r(^(#{Sinicum::Multisite::Utils.all_root_paths.join("|")})(/|$))
        sincum_url_for(options).sub(regexp, '/')
      end
    end
  end
end
