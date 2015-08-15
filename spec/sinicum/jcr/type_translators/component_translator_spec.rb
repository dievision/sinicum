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

        [:mgnl4, :mgnl5].each do |mgnl_version|
          it "should return nothing for a default node in #{mgnl_version}" do
            result = ComponentTranslator.initialize_node(
              read_default_node_json("website", "mgnl:contentNode", nil, mgnl_version))
            result.should be nil
          end

          it "should return a page for a page instance in #{mgnl_version}" do
            json = read_default_node_json(
              "website",
              "mgnl:page",
              "myModule:pages/homepage",
              mgnl_version)
            stub_const("MyModule::Pages::Homepage", mock_class)

            result = ComponentTranslator.initialize_node(json)
            result.should be_kind_of(mock_class)
          end

          it "should handle module names with dashes in #{mgnl_version}" do
            json = read_default_node_json(
              "website",
              "mgnl:page",
              "myModule:pages/homepage",
              mgnl_version)
            stub_const("MyModule::Pages::Homepage", mock_class)

            result = ComponentTranslator.initialize_node(json)
            result.should be_kind_of(mock_class)
          end

          it "should return nothing if a page class is not defined in #{mgnl_version}" do
            json = read_default_node_json(
              "website",
              "mgnl:page",
              "myModule:pages/homepage",
              mgnl_version)

            result = ComponentTranslator.initialize_node(json)
            result.should be nil
          end

          it "should return a page for a component instance in #{mgnl_version}" do
            json = read_default_node_json(
              "website",
              "mgnl:component",
              "myModule:components/path/teaser",
              mgnl_version)
            stub_const("MyModule::Components::Path::Teaser", mock_class)

            result = ComponentTranslator.initialize_node(json)
            result.should be_kind_of(mock_class)
          end
        end
      end
    end
  end
end
