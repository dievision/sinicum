module Sinicum
  module Navigation
    # Public: Wrapper around the navigation element array that exposes a
    # NavigationStatus in the #each iteration.
    class NavigationElementList
      include Enumerable

      def initialize(navigation_elements)
        @navigation_elements = navigation_elements
      end

      def each(&block)
        return unless @navigation_elements
        count = 0
        @navigation_elements.each do |el|
          block.call(el, NavigationStatus.new(@navigation_elements.size, count))
          count += 1
        end
      end

      def size
        @navigation_elements.size
      end

      def first
        @navigation_elements.first
      end

      def last
        @navigation_elements.last
      end
    end
  end
end
