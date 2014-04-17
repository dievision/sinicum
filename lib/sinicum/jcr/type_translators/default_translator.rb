module Sinicum
  module Jcr
    module TypeTranslators
      # Public: Identifies all nodes as belonging to the `Node` class. Should be
      # used as the last TypeTranslator in a chain.
      class DefaultTranslator
        def self.initialize_node(json)
          ::Sinicum::Jcr::Node.new(json_response: json)
        end
      end
    end
  end
end
