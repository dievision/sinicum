require 'spec_helper'

module Sinicum
  module Jcr
    module Cache
      describe SiteCache do
        let(:prefix) { "http://content.dievision.de:80/sinicum-rest" }
        let(:api_response) do
          File.read(File.dirname(__FILE__) + "/../../../fixtures/api/cache_global.json")
        end

        before(:each) do
          ::Sinicum::Jcr::ApiQueries.configure_jcr = { host: "content.dievision.de" }
        end

        before(:each) do
          stub_request(:get, "#{prefix}/_cache/site/dievision").to_return(
            body: api_response,
            headers: { "Content-Type" => "application/json" }
          )
        end

        it "should return the current key" do
          expect(SiteCache.new.current_key_for("/dievision")).to eq("a11cd0d31248427cbadfd8a7bc51e04e96e4de98")
        end
      end
    end
  end
end
