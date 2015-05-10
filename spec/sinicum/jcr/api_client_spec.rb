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

          ApiQueries.should_receive(:http_client).and_return(http_client)
          http_client.should_receive(:get).with(
            client_base_url + path).and_return(response)

          subject.api_get(path)
        end

        it "should delegate to the ApiQueries post method with query parameters" do
          path = "/path/to/url"
          query = { query: { param: "value" } }

          ApiQueries.should_receive(:http_client).and_return(http_client)
          http_client.should_receive(:get).with(
            client_base_url + path, query).and_return(response)

          subject.api_get(path, query)
        end
      end

      describe "POST" do
        it "should delegate to the ApiQueries post method" do
          path = "/path/to/url"

          ApiQueries.should_receive(:http_client).and_return(http_client)
          http_client.should_receive(:post).with(
            client_base_url + path).and_return(response)

          subject.api_post(path)
        end

        it "should delegate to the ApiQueries post method with query parameters" do
          path = "/path/to/url"
          query = { query: { param: "value" } }

          ApiQueries.should_receive(:http_client).and_return(http_client)
          http_client.should_receive(:post).with(
            client_base_url + path, query).and_return(response)

          subject.api_post(path, query)
        end
      end
    end
  end
end
