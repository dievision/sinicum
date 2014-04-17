module Sinicum
  module Content
    # Public: Fetches the content from Magnolia based on the path of the request.
    class WebsiteContentResolver
      def self.find_for_path(path)
        ::Sinicum::Jcr::Node.find_by_path(:website, path) if path
      end
    end
  end
end
