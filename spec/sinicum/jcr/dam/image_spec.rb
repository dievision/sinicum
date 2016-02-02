require 'spec_helper'

module Sinicum
  module Jcr
    module Dam
      describe Document do
        let(:api_response) do
          File.read(File.dirname(__FILE__) + "/../../../fixtures/api/image_mgnl5.json")
        end
        let(:json) { MultiJson.load(api_response).first }

        subject do
          ::Sinicum::Jcr::NodeInitializer.initialize_node_from_json(json)
        end

        describe "when created from JSON" do
          it "should have correct attributes" do
            expect(subject).to be_kind_of Image
            expect(subject).to be_kind_of Document
            expect(subject.width).to eq(300)
            expect(subject.height).to eq(110)
          end
        end

        describe "alt tag" do
          it "should take the alt attribute from the subject" do
            expect(subject.alt).to eq("A subject")
          end

          it "should return an empty string if no subject is given" do
            allow(subject).to receive(:[]).with(:subject).and_return(nil)
            expect(subject.alt).to eq("")
          end
        end

        describe "height and width" do
          it "should consider a converter for the width" do
            expect(subject.width("teaser")).to eq(960)
          end

          it "should consider a converter for the height" do
            expect(subject.height("teaser")).to eq(444)
          end
        end
      end
    end
  end
end
