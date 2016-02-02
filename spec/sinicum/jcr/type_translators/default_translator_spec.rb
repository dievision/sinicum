require 'spec_helper'

module Sinicum
  module Jcr
    module TypeTranslators
      describe DefaultTranslator do
        it "should return a Node instance" do
          result = DefaultTranslator.initialize_node(read_default_node_json)
          expect(result.class).to eq(::Sinicum::Jcr::Node)
        end

        it "should return a properly initialized instance" do
          result = DefaultTranslator.initialize_node(read_default_node_json)
          expect(result.uuid).to eq("21cbc762-bdcd-4520-9eff-1928986fb419")
        end
      end
    end
  end
end
