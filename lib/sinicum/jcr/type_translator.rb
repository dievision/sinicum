module Sinicum
  module Jcr
    # Public: Manages TypeTranslators in a Rails Middleware inspired way.
    #
    # A TypeTranslator is a class that translates the information on a node
    # given by the node's JSON representation in a class that will be
    # initialized with the node's data.
    # Please note, that DefaultTranslator should always be the last translator in
    # the array.
    class TypeTranslator
      DEFAULT_TRANSLATORS = [
        Sinicum::Jcr::TypeTranslators::DataTranslator,
        Sinicum::Jcr::TypeTranslators::ImagingAppTranslator,
        Sinicum::Jcr::TypeTranslators::ComponentTranslator,
        Sinicum::Jcr::TypeTranslators::DefaultTranslator]

      def self.use(clazz)
        translators.insert(0, clazz)
      end

      def self.list
        translators
      end

      def self.clear
        @translators = []
      end

      def self.reset
        @translators = DEFAULT_TRANSLATORS.dup
      end

      def self.translators
        @translators ||= DEFAULT_TRANSLATORS.dup
      end
    end
  end
end
