module Sinicum
  module Navigation
    # Public: Wrapper around the navigation element array that exposes a
    # NavigationStatus in the #each iteration.
    class NavigationElementList
      include Enumerable

      def initialize(navigation_elements = [])
        @navigation_elements = navigation_elements
      end

      def each(&block)
        return if empty?
        count = 0
        @navigation_elements.each do |el|
          block.call(el, NavigationStatus.new(@navigation_elements.size, count))
          count += 1
        end
      end

      def size
        @navigation_elements.size || 0
      end

      def first
        @navigation_elements.first
      end

      def last
        @navigation_elements.last
      end

      def empty?
        size == 0
      end
    end
  end
end
