module Sinicum
  module Navigation
    # Public: Standard implementation for the navigation.
    #
    # Expects the pages in the repository to provide the following attributes:
    #
    # nav_title    - The title of the page that should be used specifically
    #                for the navigation.
    # title        - The normal title of the page. Used for the navigation as
    #                well if `nav_title` is not present.
    # nav_hidden   - Checkbox-based attribute that indicates if the page
    #                should not show up in the navigation.
    class DefaultNavigationElement
      include NavigationElement
      DEFAULT_PROPERTIES = %w(title nav_title nav_hidden)

      def title
        @properties["nav_title"].presence || @properties["title"]
      end

      def self.navigation_properties
        DEFAULT_PROPERTIES
      end

      def self.filter_node(json_element)
        !!(json_element["properties"] && json_element["properties"]["nav_hidden"] == true)
      end
    end
  end
end
