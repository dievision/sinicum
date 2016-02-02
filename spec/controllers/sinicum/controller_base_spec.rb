require 'spec_helper'

module Sinicum
  describe ApplicationController do
    let(:node) { Jcr::Node.new }

    before(:each) do
      allow(Content::Aggregator).to receive(:original_content).and_return(node)
      allow(Content::WebsiteContentResolver).to receive(:find_for_path).and_return(node)
      allow(node).to receive(:mgnl_template).and_return("something")
    end

    it "should remove the html_ending" do
      get :index, format: "html"
      expect(response).to redirect_to("/home")
    end

    it "should ignore and conserve query strings" do
      get :index, format: "html", key: "value"
      expect(response).to redirect_to("/home?key=value")
    end

    it "should ignore post requests" do
      post :index, format: "html"
      expect(response.status).to eq(200)
    end

    describe "layout" do
      it "should render with the application layout if no matching file is found" do
        get :index
        expect(response).to render_template("application")
      end

      it "should render with the application layout if no matching file is found" do
        allow(node).to receive(:mgnl_template).and_return("layout_name")
        get :index
        expect(response).to render_template("layout_name")
      end

      it "should handle Magnolia 4.5-style layouts" do
        allow(node).to receive(:mgnl_template).and_return("my_module:pages/test")
        get :index
        expect(response).to render_template("my_module/test")
      end

      it "should handle Magnolia 4.5-style layouts with dashes" do
        allow(node).to receive(:mgnl_template).and_return("my-module:pages/test")
        get :index
        expect(response).to render_template("my-module/test")
      end

      it "should handle the redirect template" do
        allow(node).to receive(:mgnl_template).and_return("my-module:pages/redirect")
        allow(node).to receive(:[]).with(:redirect_link).and_return("/en/root")
        get :index
        expect(response).to redirect_to("/en/root")
      end
    end
  end
end
