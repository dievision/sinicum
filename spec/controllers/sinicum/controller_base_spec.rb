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

      describe "redirect template" do
        it "should redirect to the :redirect_link property as an external link" do
          allow(node).to receive(:mgnl_template).and_return("my-module:pages/redirect")
          allow(node).to receive(:[]).with(:redirect_link).and_return("/en/root")
          get :index
          expect(response).to redirect_to("/en/root")
        end

        it "should redirect to the :redirect_link property as an internal link" do
          allow(node).to receive(:mgnl_template).and_return("my-module:pages/redirect")
          allow(node).to receive(:[]).with(:redirect_link).and_return("/en/root")
          get :index
          expect(response).to redirect_to("/en/root")
        end

        it "should redirect to the :redirect_link prior to the :external_redirect_link" do
          allow(node).to receive(:mgnl_template).and_return("my-module:pages/redirect")
          allow(node).to receive(:[]).with(:redirect_link).and_return("/en/root")
          allow(node).to receive(:[]).with(:external_redirect_link).and_return("http://www.web.com")
          get :index
          expect(response).to redirect_to("/en/root")
        end

        it "should redirect to the :external_redirect_link property if no :redirect_link" do
          allow(node).to receive(:mgnl_template).and_return("my-module:pages/redirect")
          allow(node).to receive(:[]).with(:redirect_link).and_return(nil)
          allow(node).to receive(:[]).with(:external_redirect_link).and_return("http://www.web.com")
          get :index
          expect(response).to redirect_to("http://www.web.com")
        end

        it "should ignore the anchor for external link" do
          allow(node).to receive(:mgnl_template).and_return("my-module:pages/redirect")
          allow(node).to receive(:[]).with(:redirect_link).and_return(nil)
          allow(node).to receive(:[]).with(:external_redirect_link).and_return("http://www.web.com")
          allow(node).to receive(:[]).with(:anchor).and_return("#123456abcdef")
          get :index
          expect(response).to redirect_to("http://www.web.com")
        end
      end
    end
  end
end
