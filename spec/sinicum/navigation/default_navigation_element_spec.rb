require 'spec_helper'

module Sinicum
  module Navigation
    describe DefaultNavigationElement do
      it "should return the standard elements" do
        DefaultNavigationElement.navigation_properties
          .should eq(%w(title nav_title nav_hidden))
      end

      it "should not filter a node by default" do
        DefaultNavigationElement.filter_node({}).should be false
      end

      it "should filter a node with the nav_hidden_attribute" do
        json = { "properties" => { "nav_hidden" => true } }
        DefaultNavigationElement.filter_node(json).should be true
      end

      it "should not filter a node with the nav_hidden_attribute set to false" do
        json = { "properties" => { "nav_hidden" => false } }
        DefaultNavigationElement.filter_node(json).should be false
      end

      it "should return the title of a node" do
        el = DefaultNavigationElement.new(nil, nil, nil, { "title" => "Title" }, nil)
        el.title.should eq("Title")
      end

      it "should return the navigation title of a node if it exists" do
        el = DefaultNavigationElement.new(
          nil,
          nil,
          nil,
          {
            "title" => "Title",
            "nav_title" => "Navigation Title"
          },
          nil
        )
        el.title.should eq("Navigation Title")
      end
    end
  end
end
