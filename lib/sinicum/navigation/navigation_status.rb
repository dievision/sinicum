module Sinicum
  module Navigation
    # Public: Provides meta-information about the status of a NavigationElement
    # in the iteration.
    class NavigationStatus
      attr_reader :size, :count

      def initialize(size, count)
        @size = size
        @count = count
      end

      def first?
        count == 0
      end

      def last?
        count == size - 1
      end

      def to_s
        self.class.to_s + ": " +
          { size: @size, count: @count, :first? => first?, :last? => last? }.inspect
      end
    end
  end
end