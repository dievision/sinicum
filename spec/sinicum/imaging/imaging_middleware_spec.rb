require 'spec_helper'

module Sinicum
  module Imaging
    describe ImagingMiddleware do
      include Rack::Test::Methods

      let(:inner_app) do
        ->(env) { [200, { "Content-Type" => "text/plain" }, "Downstream Response"] }
      end
      let(:app) { ImagingMiddleware.new(inner_app) }

      let(:mock_file) { File.absolute_path("../../../fixtures/mock_image.gif", __FILE__) }

      it "should be ok" do
        get "/"
        expect(last_response).to match(/Downstream Response/)
      end

      it "should return 404 if the file requested does not exist" do
        allow(::Sinicum::Imaging::Imaging).to receive(:rendered_resource).and_return(nil)
        get "/damfiles/default/path/to/file"
        expect(last_response.status).to eq(404)
      end

      describe "request to an existing file" do
        before(:each) do
          mock_resource = double("resource")
          allow(mock_resource).to receive(:path) { mock_file }
          allow(mock_resource).to receive(:filename) { "mock_image.gif" }
          allow(mock_resource).to receive(:fingerprint) { "de89466a9267dccc7712379f44e6cd85" }
          allow(::Sinicum::Imaging::Imaging).to receive(:rendered_resource).and_return(mock_resource)
        end

        it "should be successful" do
          get "/damfiles/default/path/to/file-de89466a9267dccc7712379f44e6cd85"
          expect(last_response.status).to eq(200)
          get "/dmsfiles/default/path/to/file-de89466a9267dccc7712379f44e6cd85"
          expect(last_response.status).to eq(200)
        end

        it "should set the filename header" do
          get "/damfiles/default/path/to/file-de89466a9267dccc7712379f44e6cd85"
          cd_header = last_response.headers["Content-Disposition"]
          expect(cd_header).to match(/inline; filename="mock_image.gif"/)
          get "/dmsfiles/default/path/to/file-de89466a9267dccc7712379f44e6cd85"
          cd_header = last_response.headers["Content-Disposition"]
          expect(cd_header).to match(/inline; filename="mock_image.gif"/)
        end

        it "should set the cache header to one week" do
          Rails.configuration.action_controller.perform_caching = true
          get "/damfiles/default/path/to/file-de89466a9267dccc7712379f44e6cd85"
          cd_header = last_response.headers["Cache-Control"]
          expect(cd_header).to match(/max-age=604800, public/)
          Rails.configuration.action_controller.perform_caching = false
        end

        it "should set the cache header to one week (dms)" do
          Rails.configuration.action_controller.perform_caching = true
          get "/dmsfiles/default/path/to/file-de89466a9267dccc7712379f44e6cd85"
          cd_header = last_response.headers["Cache-Control"]
          expect(cd_header).to match(/max-age=604800, public/)
          Rails.configuration.action_controller.perform_caching = false
        end
      end

      describe "request images whith the original prefix" do
        it "should be successful" do
          allow(::Sinicum::Imaging::Imaging).to receive(:rendered_resource).and_return(nil)
          get "/dam/path/to/file"
          expect(last_response.body).to_not match(/Downstream Response/)
          get "/dms/path/to/file"
          expect(last_response.body).to_not match(/Downstream Response/)
        end
      end
    end
  end
end
