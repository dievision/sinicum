require 'spec_helper'
require 'digest/md5'

module Sinicum
  module Jcr
    describe NodeQueries do
      let(:api_response) { File.read(File.dirname(__FILE__) + "/../../fixtures/api/homepage.json") }
      let(:json_response) { MultiJson.load(api_response) }
      let(:prefix) { "http://content.dievision.de:80/sinicum-rest" }

      before(:each) do
        ApiQueries.configure_jcr = { host: "content.dievision.de" }
      end

      describe "web access" do
        before(:each) do
          stub_request(:get, "#{prefix}/website/home")
            .to_return(body: api_response, headers: { "Content-Type" => "application/json" })
          stub_request(:get, "#{prefix}/website/_uuid/21cbc762-bdcd-4520-9eff-1928986fb419")
            .to_return(body: api_response, headers: { "Content-Type" => "application/json" })
        end

        xit "should query for a node by path" do
          Node.should_receive(:new).with(json_response: json_response.first)
          result = Node.find_by_path("website", "home")
          expect(result).to be_a(Sinicum::Jcr::Node)
        end

        xit "should query for a node by uuid" do
          Node.should_receive(:new).with(json_response: json_response.first)
          result = Node.find_by_uuid("website", "21cbc762-bdcd-4520-9eff-1928986fb419")
          expect(result).to be_a(Sinicum::Jcr::Node)
        end
      end

      describe "authentication" do
        it "should use no authentication if no user and password is configured" do
          stub_request(:get, "#{prefix}/website/home")
            .to_return(body: api_response, headers: { "Content-Type" => "application/json" })
          expect(Node).to receive(:new).with(json_response: json_response.first)

          Node.find_by_path("website", "home")
        end

        it "should use no authentication if no user and password is configured" do
          stub_request(:get, "content.dievision.de/sinicum-rest/website/home")
            .to_return(body: api_response, headers: { "Content-Type" => "application/json" })
          ApiQueries.configure_jcr = {
            host: "content.dievision.de",
            username: "user",
            password: "pass"
          }
          expect(Node).to receive(:new).with(json_response: json_response.first)

          Node.find_by_path("website", "home")
        end
      end

      describe "streaming" do
        it "should construct the right url for streaming an attribute and stream the content" do
          skip "The actual test seems wrong"
          begin
            image_file = File.join(File.dirname(__FILE__), "..", "..", "fixtures", "mock_image.gif")
            tmp_file = File.join(File.dirname(__FILE__), "..", "..", "fixtures", "tmp.gif")
            stub_request(:get, "http://content.dievision.de/sinicum-rest/dam/_binary/some/path")
              .with(query: { "property" => "jcr:data" }).to_return(body: File.new(image_file))

            target = File.open(tmp_file, "wb")
            Node.stream_attribute(
              "dam", "/some/path", "jcr:data", File.open(tmp_file, "wb")
            )
            WebMock.should have_requested(
              :get,
              "http://content.dievision.de/sinicum-rest/dam/_binary/some/path"
            ).with(query: { "property" => "jcr:data" })
            target.close

            expect(Digest::MD5.hexdigest(File.read(tmp_file))).to eq(
              Digest::MD5.hexdigest(File.read(tmp_file)))
          ensure
            File.delete(tmp_file) if File.exist?(tmp_file)
          end
        end
      end

      describe "queries" do
        let(:api_response) do
          File.read(File.dirname(__FILE__) + "/../../fixtures/api/query_result.json")
        end
        let(:json_response) { MultiJson.load(api_response) }

        before(:each) do
          stub_request(
            :get,
            /content\.dievision\.de\/sinicum-rest\/website\/_query/
          ).to_return(
            status: 200,
            body: api_response,
            headers: { "Content-Type" => "application/json" }
          )
        end

        it "should return results based on a query" do
          expect(Node).to receive(:new).with(json_response: json_response.first)
          expect(Node).to receive(:new).with(json_response: json_response.last)
          result = Node.query("website", :xpath, "/jcr:root/path//element(*, mgnl:page)")
          expect(result).to be_kind_of(Array)
        end

        it "should query for multiple uuids separated by comma" do
          result = Node.find_by_uuids("website", "995a776f-242e-453a-9422-d0b7e8e9c068,
            bba4bfcd-8347-40d0-9bb6-504ddde1c5a1")
          expect(result).to be_kind_of(Array)
          expect(result.first.uuid).to eq("995a776f-242e-453a-9422-d0b7e8e9c068")
          expect(result.second.uuid).to eq("bba4bfcd-8347-40d0-9bb6-504ddde1c5a1")
        end

        it "should query for multiple uuids in an array" do
          result = Node.find_by_uuids("website", ["995a776f-242e-453a-9422-d0b7e8e9c068",
            "bba4bfcd-8347-40d0-9bb6-504ddde1c5a1"])
          expect(result).to be_kind_of(Array)
          expect(result.first.uuid).to eq("995a776f-242e-453a-9422-d0b7e8e9c068")
          expect(result.second.uuid).to eq("bba4bfcd-8347-40d0-9bb6-504ddde1c5a1")
        end
      end
    end
  end
end
