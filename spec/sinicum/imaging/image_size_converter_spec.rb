require 'spec_helper'

module Sinicum
  module Imaging
    describe ImageSizeConverter do
      let(:image) do
        document = double("document")
        document.stub(:[]).and_return(nil)
        document.stub(:[]).with(:width).and_return(100)
        document.stub(:[]).with(:height).and_return(50)
        image = Sinicum::Jcr::Dam::Image.new
        image.stub(:[]).and_return(nil)
        image.stub(:[]).with(:document).and_return(document)
      end

      it "should convert the width" do
        conv = ImageSizeConverter.new(image, "teaser")
        conv.width.should eq(960)
      end

      it "should convert the height" do
        conv = ImageSizeConverter.new(image, "teaser")
        conv.height.should eq(444)
      end
    end
  end
end
