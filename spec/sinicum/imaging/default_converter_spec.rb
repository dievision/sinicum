require 'spec_helper'

module Sinicum::Imaging
  describe DefaultConverter do
    let(:document) {
      doc = double("document")
      allow(doc).to receive(:'[]').and_return(nil)
      doc
    }
    let(:metadata) { double("metadata") }
    subject { DefaultConverter.new(nil) }

    before(:each) do
      subject.document = document
    end

    it "should return the file extension for a Magnolia 5 document" do
      allow(document).to receive(:'[]').with(:'jcr:content').and_return(metadata)
      allow(metadata).to receive(:'[]').with(:extension).and_return("jpeg")

      expect(subject.format).to eq(".jpeg")
    end

    it "should return the file extension for a Magnolia 4 document" do
      allow(document).to receive(:'[]').with(:'document').and_return(metadata)
      allow(metadata).to receive(:'[]').with(:extension).and_return("png")

      expect(subject.format).to eq(".png")
    end
  end
end
