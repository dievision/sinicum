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
        last_response.should =~ /Downstream Response/
      end

      it "should return 404 if the file requested does not exist" do
        ::Sinicum::Imaging::Imaging.stub(:rendered_resource).and_return(nil)
        get "/damfiles/default/path/to/file"
        last_response.status.should eq(404)
      end

      describe "request to an existing file" do
        before(:each) do
          mock_resource = double("resource")
          mock_resource.stub(:path) { mock_file }
          mock_resource.stub(:filename) { "mock_image.gif" }
          mock_resource.stub(:fingerprint) { "de89466a9267dccc7712379f44e6cd85" }
          ::Sinicum::Imaging::Imaging.stub(:rendered_resource).and_return(mock_resource)
        end

        it "should be successful" do
          get "/damfiles/default/path/to/file-de89466a9267dccc7712379f44e6cd85"
          last_response.status.should eq(200)
          get "/dmsfiles/default/path/to/file-de89466a9267dccc7712379f44e6cd85"
          last_response.status.should eq(200)
        end

        it "should set the filename header" do
          get "/damfiles/default/path/to/file-de89466a9267dccc7712379f44e6cd85"
          cd_header = last_response.headers["Content-Disposition"]
          cd_header.should =~ /inline; filename="mock_image.gif"/
          get "/dmsfiles/default/path/to/file-de89466a9267dccc7712379f44e6cd85"
          cd_header = last_response.headers["Content-Disposition"]
          cd_header.should =~ /inline; filename="mock_image.gif"/
        end

        it "should set the cache header to one week" do
          Rails.configuration.action_controller.perform_caching = true
          get "/damfiles/default/path/to/file-de89466a9267dccc7712379f44e6cd85"
          cd_header = last_response.headers["Cache-Control"]
          cd_header.should =~ /max-age=604800, public/
          Rails.configuration.action_controller.perform_caching = false
        end

        it "should set the cache header to one week (dms)" do
          Rails.configuration.action_controller.perform_caching = true
          get "/dmsfiles/default/path/to/file-de89466a9267dccc7712379f44e6cd85"
          cd_header = last_response.headers["Cache-Control"]
          cd_header.should =~ /max-age=604800, public/
          Rails.configuration.action_controller.perform_caching = false
        end
      end

      describe "request images whith the original prefix" do
        it "should be successful" do
          ::Sinicum::Imaging::Imaging.stub(:rendered_resource).and_return(nil)
          get "/dam/path/to/file"
          last_response.body.should_not =~ /Downstream Response/
          get "/dms/path/to/file"
          last_response.body.should_not =~ /Downstream Response/
        end
      end
    end
  end
end
