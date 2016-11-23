require 'spec_helper'

module Sinicum
  module Multisite
    describe MultisiteMiddleware, :type => :request do
      let(:api_response_multisite) { File.read(File.dirname(__FILE__) + "/../../fixtures/api/dievision_multisite.json") }
      let(:api_response_multisite2) { File.read(File.dirname(__FILE__) + "/../../fixtures/api/sinicum_multisite.json") }
      let(:api_response_website) { File.read(File.dirname(__FILE__) + "/../../fixtures/api/multisite_home.json") }

      before(:example) do
        Sinicum::Jcr::ApiQueries.configure_jcr = { host: "content.dievision.de" }
      end

      describe "adjust request paths" do
        before(:example) do
          stub_request(:get, /.*sinicum-rest\/website.*/)
            .to_return(body: api_response_website, headers: { "Content-Type" => "application/json" })
          stub_request(:get, /.*sinicum-rest\/multisite.*/)
            .to_return(body: api_response_multisite, headers: { "Content-Type" => "application/json" })
        end

        it "should trigger multisite for a subnode" do
          get '/home'
          expect(request.path).to eq("/dievision/home")
          expect(request.session[:multisite_root]).to eq("/dievision")
        end

        it "should trigger multisite for a not existing node" do
          get '/test'
          expect(request.path).to eq("/dievision/test")
          expect(request.session[:multisite_root]).to eq("/dievision")
        end

        it "should trigger multisite for a rootnode and not redirect" do
          get '/dievision'
          expect(request.path).to eq("/dievision")
          expect(request.session[:multisite_root]).to eq("/dievision")

          get '/dievision/'
          expect(request.path).to eq("/dievision/")
          expect(request.session[:multisite_root]).to eq("/dievision")
        end

        it "should trigger multisite for a rootnode and a subnode and redirect" do
          get '/dievision/home'
          expect(request.path).to eq("/dievision/home")
          expect(response).to have_http_status(:ok)
          expect(request.session[:multisite_root]).to eq("/dievision")

          get '/dievision/home'
          expect(request.path).to eq("/dievision/home")
          expect(response).to redirect_to("/home")
          expect(request.session[:multisite_root]).to eq("/dievision")

          get '/home'
          expect(request.path).to eq("/dievision/home")
          expect(response).to have_http_status(:ok)
          expect(request.session[:multisite_root]).to eq("/dievision")
        end

        it "should use the session after a first request" do
          get '/home'
          expect(request.path).to eq("/dievision/home")

          stub_request(:get, /.*sinicum-rest\/multisite.*/)
            .to_return(body: "[]", headers: { "Content-Type" => "application/json" })

          get '/test'
          expect(request.path).to eq("/dievision/test")
        end

        it "should change the root_node" do
          get '/home'
          expect(request.path).to eq("/dievision/home")

          stub_request(:get, /.*sinicum-rest\/multisite.*/)
            .to_return(body: api_response_multisite2, headers: { "Content-Type" => "application/json" })

          get '/test'
          expect(request.path).to eq("/sinicum/test")
        end
      end

      describe "no change in request paths" do
        before(:example) do
          stub_request(:get, /.*sinicum-rest\/website.*/)
            .to_return(body: api_response_website, headers: { "Content-Type" => "application/json" })
          stub_request(:get, /.*sinicum-rest\/multisite.*/)
            .to_return(body: "[]", headers: { "Content-Type" => "application/json" })
        end

        it "should pass the request through unchanged" do
          get '/unmodified'
          expect(request.path).to eq("/unmodified")
        end
      end
    

      context "in production mode" do
        before(:example) do
          Rails.configuration.x.multisite_production = true
          stub_request(:get, /.*sinicum-rest\/website.*/)
            .to_return(body: api_response_website, headers: { "Content-Type" => "application/json" })
        end
        
        it "should get redirected" do
          host! "sinicum.example.de"
          stub_request(:get, /.*sinicum-rest\/multisite.*?primary_domain.*/)
            .to_return(body: "[]", headers: { "Content-Type" => "application/json" })
          stub_request(:get, /.*sinicum-rest\/multisite.*?alias_domains.*/)
            .to_return(body: api_response_multisite, headers: { "Content-Type" => "application/json" })

          get '/home'
          expect(response).to redirect_to("http://magnolia.example.de/home")
        end

        it "should not get redirect" do
          host! "magnolia.example.de"
          stub_request(:get, /.*sinicum-rest\/multisite.*/)
            .to_return(body: "[]", headers: { "Content-Type" => "application/json" })

          get '/home'
          expect(response).to have_http_status(:ok)
          expect(request.path).to eq("/home")
        end

        it "should be bypassed because of the path" do
          host! "magnolia.example.de"
          stub_request(:get, /.*sinicum-rest\/multisite.*/)
            .to_return(body: api_response_multisite, headers: { "Content-Type" => "application/json" })

          get '/sidekiq'
          expect(response).to have_http_status(:ok)
          expect(request.path).to eq("/sidekiq")
          get '/assets'
          expect(response).to have_http_status(:ok)
          expect(request.path).to eq("/assets")
          get '/home'
          expect(response).to have_http_status(:ok)
          expect(request.path).to eq("/dievision/home")
        end

        it "should still bypass assets if config is not set" do
          host! "magnolia.example.de"
          Rails.configuration.x.multisite_ignored_paths = [/#{Regexp.quote(Rails.configuration.assets.prefix)}/]
          stub_request(:get, /.*sinicum-rest\/multisite.*/)
            .to_return(body: api_response_multisite, headers: { "Content-Type" => "application/json" })

          get '/sidekiq'
          expect(response).to have_http_status(:ok)
          expect(request.path).to eq("/dievision/sidekiq")
          get '/assets'
          expect(response).to have_http_status(:ok)
          expect(request.path).to eq("/assets")
        end
      end
    end

    describe "MultisiteMiddleware", type: :helper do
      it "should cut the url" do
        session[:multisite_root] = "/dievision"
        expect(helper.url_for "/dievision/home").to eq("/home")
      end

      it "should not cut the url" do
        expect(helper.url_for "/dievision/home").to eq("/dievision/home")
      end
    end
  end
end
