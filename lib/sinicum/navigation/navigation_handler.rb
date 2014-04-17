module Sinicum
  module Navigation
    # Public: Handles the API communication and initializes the
    # NavigationElement instances.
    class NavigationHandler
      include Jcr::ApiClient

      def initialize(axis, base_node_or_path, navigation_element_class, options = {})
        @navigation_element_class = navigation_element_class
        if axis == :children
          @elements = fetch_children(base_node_or_path, options[:depth])
        elsif axis == :parents
          @elements = fetch_parents(base_node_or_path)
        end
      end

      def elements
        NavigationElementList.new(@elements)
      end

      def self.children(base_node_or_path, depth,
          navigation_element_class = DefaultNavigationElement)
        new(:children, base_node_or_path, navigation_element_class, depth: depth)
      end

      def self.parents(base_node_or_path, navigation_element_class = DefaultNavigationElement)
        new(:parents, base_node_or_path, navigation_element_class)
      end

      private

      def fetch_children(base_node, depth)
        url = "/_navigation/children#{base_node_url_part(base_node)}"
        result = api_get(
          url,
          "depth" => depth,
          "properties" => @navigation_element_class.navigation_properties.join(";"))
        if result.ok?
          json = MultiJson.load(result.body)
          initialize_from_json(json)
        end
      end

      def fetch_parents(base_node)
        url = "/_navigation/parents#{base_node_url_part(base_node)}"
        result = api_get(
          url, "properties" => @navigation_element_class.navigation_properties.join(";"))
        if result.ok?
          json = MultiJson.load(result.body)
          initialize_from_json(json)
        end
      end

      def initialize_from_json(json)
        result = []
        json.each do |el|
          element = initialize_element(el)
          result << element if element
        end
        @elements = result
      end

      def initialize_element(el)
        result = nil
        unless @navigation_element_class.filter_node(el)
          children = resolve_children(el)
          element = @navigation_element_class.new(
            el["uuid"], el["path"], el["depth"], el["properties"], children)
          result = element
        end
        result
      end

      def resolve_children(el)
        children = []
        if el["children"]
          el["children"].each do |child_el|
            child = initialize_element(child_el)
            children << child if child
          end
        end
        children.size > 0 ? children : nil
      end

      def base_node_url_part(base_node)
        if base_node.respond_to?(:uuid)
          url_part = "/" + base_node.uuid
        else
          url_part = base_node
        end
        url_part
      end
    end
  end
end
