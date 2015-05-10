require 'spec_helper'

module Sinicum
  module Jcr
    module TypeTranslators
      describe ComponentTranslator do
        let(:mock_class) do
          Class.new do
            def initialize(*)
            end
          end
        end
        let(:api_response) do
          File.read(File.dirname(__FILE__) +
          "/../../../fixtures/api/product.json")
        end

        let(:json) { MultiJson.load(api_response).first }

        it "should return nothing for a default node" do
          result = DataTranslator.initialize_node(read_default_node_json)
          result.should be nil
        end

        it "should return a default node when no matching class exists" do
          result = DataTranslator.initialize_node(json)
          result.should be nil
        end

        it "should initialize a new class based on the node's primary type" do
          stub_const("Microphone", mock_class)
          result = DataTranslator.initialize_node(json)
          result.should be_kind_of(mock_class)
        end
      end
    end
  end
end
