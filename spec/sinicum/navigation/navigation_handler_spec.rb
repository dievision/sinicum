require 'spec_helper'

module Sinicum
  module Navigation
    describe NavigationHandler do
      let(:prefix) { "http://content.dievision.de:80/sinicum-rest" }

      describe "children" do
        let(:api_response) do
          File.read(File.dirname(__FILE__) +
            "/../../fixtures/api/navigation_children.json")
        end

        let(:base_node) do
          node = double("base_node")
          allow(node).to receive(:uuid).and_return("745efc13-e7da-4717-9153-10fb6472ca73")
          node
        end

        before(:each) do
          ::Sinicum::Jcr::ApiQueries.configure_jcr = { host: "content.dievision.de" }

          stub_request(:get, "#{prefix}/_navigation/children/#{base_node.uuid}?depth=3&" \
            "properties=title;nav_title;nav_hidden")
            .to_return(body: api_response, headers: { "Content-Type" => "application/json" })
        end

        it "should retrieve the children for a node and filter elements" do
          handler = NavigationHandler.children(base_node, 3)
          expect(handler.elements.size).to eq(7)
        end

        it "should return the navigation elements for the node" do
          handler = NavigationHandler.children(base_node, 3)
          expect(handler.elements.first).to be_kind_of(NavigationElement)
        end

        it "should initialize the children of the elements" do
          handler = NavigationHandler.children(base_node, 3)
          expect(handler.elements.first.children.size).to eq(10)
        end
      end

      describe "parents" do
        let(:api_response) do
          File.read(File.dirname(__FILE__) +
          "/../../fixtures/api/navigation_parents.json")
        end

        let(:base_node) do
          node = double("base_node")
          allow(node).to receive(:uuid).and_return("745efc13-e7da-4717-9153-10fb6472ca73")
          node
        end

        before(:each) do
          ::Sinicum::Jcr::ApiQueries.configure_jcr = { host: "content.dievision.de" }

          stub_request(:get, "#{prefix}/_navigation/parents/#{base_node.uuid}?" \
            "properties=title;nav_title;nav_hidden")
            .to_return(body: api_response, headers: { "Content-Type" => "application/json" })
        end

        it "should retrieve the children for a node and filter elements" do
          handler = NavigationHandler.parents(base_node)
          expect(handler.elements.size).to eq(3)
        end
      end
    end
  end
end
