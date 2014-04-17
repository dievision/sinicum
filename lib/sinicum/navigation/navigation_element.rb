module Sinicum
  module Navigation
    module NavigationElement
      extend ActiveSupport::Concern

      attr_reader :uuid, :path, :depth, :properties, :children

      def initialize(uuid, path, depth, properties, children)
        @uuid = uuid
        @path = path
        @depth = depth
        @properties = properties
        @children = children
      end

      def title
      end

      def has_children?
        warn "[DEPRECATION] `has_children?` is deprecated.  Please use `children?` instead."
        @children && @children.size > 0
      end

      def children?
        @children && @children.size > 0
      end

      def children
        NavigationElementList.new(@children)
      end

      module ClassMethods
        def navigation_properties
          []
        end
      end
    end
  end
end
