require 'spec_helper'

module Sinicum
  describe ApplicationController do
    let(:node) { Jcr::Node.new }

    before(:example) do
      allow(Content::Aggregator).to receive(:original_content).and_return(node)
      allow(Content::WebsiteContentResolver).to receive(:find_for_path).and_return(node)
      allow(node).to receive(:mgnl_template).and_return("something")
      allow(Sinicum::Multisite::Utils).to receive(:all_root_paths).
          and_return(%w[/dievision /test /labs])
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

    describe "redirects" do
      it "should redirect with 302 if no status is set" do
        redirect_node = Jcr::Node.new({ redirect_link: "http://www.dievision.de/redirect_link" })
        allow(redirect_node).to receive(:mgnl_template).and_return("my-module:pages/redirect")
        allow(Content::Aggregator).to receive(:original_content).and_return(redirect_node)

        get :index

        expect(response).to redirect_to("http://www.dievision.de/redirect_link")
        expect(response.code).to eq("302")
      end

      it "should redirect with 302 if set" do
        redirect_node = Jcr::Node.new({ redirect_link: "http://www.dievision.de/redirect_link", redirect_status: "302" })
        allow(redirect_node).to receive(:mgnl_template).and_return("my-module:pages/redirect")
        allow(Content::Aggregator).to receive(:original_content).and_return(redirect_node)

        get :index

        expect(response).to redirect_to("http://www.dievision.de/redirect_link")
        expect(response.code).to eq("302")
      end

      it "should redirect with 301 if set" do
        redirect_node = Jcr::Node.new({ redirect_link: "http://www.dievision.de/redirect_link", redirect_status: 301 })
        allow(redirect_node).to receive(:mgnl_template).and_return("my-module:pages/redirect")
        allow(Content::Aggregator).to receive(:original_content).and_return(redirect_node)

        get :index

        expect(response).to redirect_to("http://www.dievision.de/redirect_link")
        expect(response.code).to eq("301")
      end
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
    end

    describe "multisite" do
      it "should cut the path helpers" do
        expect(labs_path("test")).to eq("/test")
      end

      it "should cut when url_for is used" do
        expect(controller.url_for("/dievision/test")).to eq("/test")
      end

      it "should not cut" do
        expect(asd_path("test")).to eq("/asd/test")
      end
    end
  end
end
