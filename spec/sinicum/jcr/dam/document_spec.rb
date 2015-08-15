require 'spec_helper'

module Sinicum
  module Jcr
    module Dam
      describe Document do
        let(:api_response) do
          File.read(File.dirname(__FILE__) + "/../../../fixtures/api/file_mgnl5.json")
        end
        let(:json) { MultiJson.load(api_response).first }

        subject do
          ::Sinicum::Jcr::NodeInitializer.initialize_node_from_json(json)
        end

        describe "when created from JSON" do
          it "should have correct attributes" do
            subject.should be_kind_of Document
            subject.name.should eq("Tecnotes_18_Sommer_10")
            subject.subject.should eq("TecNotes Ausgabe 18, Sommer 2010")
            subject.description.should eq("Some Description")
            subject.file_size.should eq(562_116_5)
            subject.file_name.should eq("Tecnotes_18_Sommer_10.pdf")
            subject.mime_type.should eq("application/pdf")
          end
        end

        describe "date" do
          it "should have the correct date when 'date1' is given" do
            subject.date.should eq(Date.new(2013, 06, 06))
          end

          it "should have the correct date when 'date1' is not defined" do
            subject.stub(:[]).with(:date1).and_return(nil)
            unless defined?(JRUBY_VERSION)
              # rubocop:disable all
              subject.date.should eq(DateTime.new(2010, 7, 27, 14, 41, 4.105, "+2"))
              # rubocop:enable all
            end
          end
        end

        it "should return a web-compatible path" do
          subject.path.should eq(
            "/damfiles/default/shure/support_downloads/education/tecnotes/Tecnotes_18_Sommer_10" \
            "-79209c1a63d7435f3f2179e31c104ef8.pdf")
        end

        it "should accept a 'converter_name' argument to specify the converter" do
          subject.path(converter: "some_converter").should eq(
            "/damfiles/some_converter/shure/support_downloads/education/tecnotes/" \
            "Tecnotes_18_Sommer_10-79209c1a63d7435f3f2179e31c104ef8.pdf")
        end

        describe "fingerprint" do
          let(:default_fingerprint) { "79209c1a63d7435f3f2179e31c104ef8" }

          it "should have a correct fingerprint" do
            subject.fingerprint.should eq(default_fingerprint)
          end

          it "should depend on the path" do
            subject.stub(:jcr_path).and_return("different")
            subject.send(:fingerprint).should_not eq(default_fingerprint)
            subject.send(:fingerprint).should =~ /^[a-f0-9]{32}$/
          end

          it "should depend on the id" do
            subject.stub(:id).and_return("different")
            subject.send(:fingerprint).should_not eq(default_fingerprint)
            subject.send(:fingerprint).should =~ /^[a-f0-9]{32}$/
          end

          it "should depend on the various other attributes" do
            doc = double("document")
            doc.stub(:[]).with(:"jcr:lastModified").and_return("different")
            doc.stub(:[]).with(:"jcr:lastModifiedBy").and_return("different")
            doc.stub(:[]).with(:size).and_return("different")
            subject.stub(:[]).with(:'jcr:content').and_return(doc)
            subject.send(:fingerprint).should_not eq(default_fingerprint)
            subject.send(:fingerprint).should =~ /^[a-f0-9]{32}$/
          end
        end
      end
    end
  end
end
