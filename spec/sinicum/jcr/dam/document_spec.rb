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
            expect(subject).to be_kind_of Document
            expect(subject.name).to eq("Tecnotes_18_Sommer_10")
            expect(subject.subject).to eq("TecNotes Ausgabe 18, Sommer 2010")
            expect(subject.description).to eq("Some Description")
            expect(subject.file_size).to eq(562_116_5)
            expect(subject.file_name).to eq("Tecnotes_18_Sommer_10.pdf")
            expect(subject.mime_type).to eq("application/pdf")
          end          
        end

        describe "date" do
          it "should have the correct date when 'date1' is given" do
            expect(subject.date).to eq(Date.new(2013, 06, 06))
          end

          it "should have the correct date when 'date1' is not defined" do
            allow(subject).to receive(:[]).with(:date1).and_return(nil)
            unless defined?(JRUBY_VERSION)
              expect(subject.date).to eq(DateTime.new(2010, 7, 27, 14, 41, 4.105, "+0200"))
            end
          end
        end

        it "should return a web-compatible path" do
          expect(subject.path).to eq(
            "/damfiles/default/shure/support_downloads/education/tecnotes/Tecnotes_18_Sommer_10" \
            "-79209c1a63d7435f3f2179e31c104ef8.pdf")
        end

        it "should accept a 'converter_name' argument to specify the converter" do
          expect(subject.path(converter: "some_converter")).to eq(
            "/damfiles/some_converter/shure/support_downloads/education/tecnotes/" \
            "Tecnotes_18_Sommer_10-79209c1a63d7435f3f2179e31c104ef8.pdf")
        end

        describe "fingerprint" do
          let(:default_fingerprint) { "79209c1a63d7435f3f2179e31c104ef8" }

          it "should have a correct fingerprint" do
            expect(subject.fingerprint).to eq(default_fingerprint)
          end

          it "should depend on the path" do
            allow(subject).to receive(:jcr_path).and_return("different")
            expect(subject.send(:fingerprint)).to_not eq(default_fingerprint)
            expect(subject.send(:fingerprint)).to match(/^[a-f0-9]{32}$/)
          end

          it "should depend on the id" do
            allow(subject).to receive(:id).and_return("different")
            expect(subject.send(:fingerprint)).to_not eq(default_fingerprint)
            expect(subject.send(:fingerprint)).to match(/^[a-f0-9]{32}$/)
          end

          it "should depend on the various other attributes" do
            doc = double("document")
            allow(doc).to receive(:[]).with(:"jcr:lastModified").and_return("different")
            allow(doc).to receive(:[]).with(:"jcr:lastModifiedBy").and_return("different")
            allow(doc).to receive(:[]).with(:size).and_return("different")
            allow(subject).to receive(:[]).with(:'jcr:content').and_return(doc)
            expect(subject.send(:fingerprint)).to_not eq(default_fingerprint)
            expect(subject.send(:fingerprint)).to match(/^[a-f0-9]{32}$/)
          end
        end
      end
    end
  end
end
