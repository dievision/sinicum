require 'spec_helper'

module Sinicum::Imaging
  describe DefaultConverter do
    let(:document) {
      doc = double("document")
      doc.stub(:'[]').and_return(nil)
      doc
    }
    let(:metadata) { double("metadata") }
    subject { DefaultConverter.new(nil) }

    before(:each) do
      subject.document = document
    end

    it "should return the file extension for a Magnolia 5 document" do
      document.stub(:'[]').with(:'jcr:content').and_return(metadata)
      metadata.stub(:'[]').with(:extension).and_return("jpeg")

      subject.format.should eq(".jpeg")
    end

    it "should return the file extension for a Magnolia 4 document" do
      document.stub(:'[]').with(:'document').and_return(metadata)
      metadata.stub(:'[]').with(:extension).and_return("png")

      subject.format.should eq(".png")
    end
  end
end
