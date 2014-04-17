require 'spec_helper'

module Sinicum
  describe ApplicationController do
    let(:node) { Jcr::Node.new }

    before(:each) do
      Content::Aggregator.stub(:original_content).and_return(node)
      Content::WebsiteContentResolver.stub(:find_for_path).and_return(node)
      node.stub(:mgnl_template).and_return("something")
    end

    it "should remove the html_ending" do
      get :index, format: "html"
      response.should redirect_to("/home")
    end

    it "should ignore and conserve query strings" do
      get :index, format: "html", key: "value"
      response.should redirect_to("/home?key=value")
    end

    it "should ignore post requests" do
      post :index, format: "html"
      response.status.should eq(200)
    end

    describe "layout" do
      it "should render with the application layout if no matching file is found" do
        get :index
        response.should render_template("application")
      end

      it "should render with the application layout if no matching file is found" do
        node.stub(:mgnl_template).and_return("layout_name")
        get :index
        response.should render_template("layout_name")
      end

      it "should handle Magnolia 4.5-style layouts" do
        node.stub(:mgnl_template).and_return("my_module:pages/test")
        get :index
        response.should render_template("my_module/test")
      end

      it "should handle Magnolia 4.5-style layouts with dashes" do
        node.stub(:mgnl_template).and_return("my-module:pages/test")
        get :index
        response.should render_template("my-module/test")
      end
    end
  end
end
