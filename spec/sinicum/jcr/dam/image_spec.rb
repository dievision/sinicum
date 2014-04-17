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
          it { should be_kind_of Image }
          it { should be_kind_of Document }
          its(:width) { should eq(300) }
          its(:height) { should eq(110) }
        end

        describe "alt tag" do
          it "should take the alt attribute from the subject" do
            subject.alt.should eq("A subject")
          end

          it "should return an empty string if no subject is given" do
            subject.stub(:[]).with(:subject).and_return(nil)
            subject.alt.should eq("")
          end
        end

        describe "height and width" do
          it "should consider a converter for the width" do
            subject.width("teaser").should eq(960)
          end

          it "should consider a converter for the height" do
            subject.height("teaser").should eq(444)
          end
        end
      end
    end
  end
end
