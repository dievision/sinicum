require 'spec_helper'

module Sinicum
  module Jcr
    describe ApiClient do
      mock_api_client_class = Class.new do
        include ApiClient
      end

      let(:subject) { mock_api_client_class.new }
      let(:http_client) { double :http_client }
      let(:response) { double :response }

      let(:host) { "content.dievision.de" }
      let(:client_base_url) { "http://content.dievision.de/sinicum-rest" }

      before(:each) do
        ApiQueries.configure_jcr = { host: host }
      end

      describe "GET" do
        it "should delegate to the ApiQueries get method" do
          path = "/path/to/url"

          expect(ApiQueries).to receive(:http_client).and_return(http_client)
          expect(http_client).to receive(:get).with(
            client_base_url + path, nil, {}).and_return(response)

          subject.api_get(path)
        end

        it "should delegate to the ApiQueries get method with query parameters" do
          path = "/path/to/url"
          query = { query: { param: "value" } }

          expect(ApiQueries).to receive(:http_client).and_return(http_client)
          expect(http_client).to receive(:get).with(
            client_base_url + path, query).and_return(response)

          subject.api_get(path, query, {})
        end

        it "should escape a path" do
          path = "/%7B%22auto_hd%22:false,%22autoplay_reason%22:%22unknown%22,%22default_hd%22:true"#

          expect(ApiQueries).to receive(:http_client).and_return(http_client)
          expect(http_client).to receive(:get).with(
            client_base_url + URI.escape(path), nil, {}).and_return(response)

          subject.api_get(path)
        end
      end

      describe "POST" do

        it "should delegate to the ApiQueries post method" do
          path = "/path/to/url"

          expect(ApiQueries).to receive(:http_client).and_return(http_client)
          expect(http_client).to receive(:post).with(
            client_base_url + path).and_return(response)

          subject.api_post(path)
        end

        it "should delegate to the ApiQueries post method with query parameters" do
          path = "/path/to/url"
          query = { query: { param: "value" } }

          expect(ApiQueries).to receive(:http_client).and_return(http_client)
          expect(http_client).to receive(:post).with(
            client_base_url + path, query).and_return(response)

          subject.api_post(path, query)
        end
      end
    end
  end
end
