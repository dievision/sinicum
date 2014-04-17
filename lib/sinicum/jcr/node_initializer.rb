module Sinicum
  module Jcr
    # Responsible for Initializing a node based on the nodes' JSON data with the
    # correct class.
    class NodeInitializer
      def self.initialize_node_from_json(json)
        node = nil
        TypeTranslator.list.each do |translator|
          node = translator.initialize_node(json)
          break if node
        end
        node
      end
    end
  end
end
