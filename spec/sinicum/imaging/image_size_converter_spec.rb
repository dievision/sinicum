require 'spec_helper'

module Sinicum
  module Imaging
    describe ImageSizeConverter do
      let(:image) do
        document = double("document")
        allow(document).to receive(:[]).and_return(nil)
        allow(document).to receive(:[]).with(:width).and_return(100)
        allow(document).to receive(:[]).with(:height).and_return(50)
        image = Sinicum::Jcr::Dam::Image.new
        allow(image).to receive(:[]).and_return(nil)
        allow(image).to receive(:[]).with(:document).and_return(document)
      end

      it "should convert the width" do
        conv = ImageSizeConverter.new(image, "teaser")
        expect(conv.width).to eq(960)
      end

      it "should convert the height" do
        conv = ImageSizeConverter.new(image, "teaser")
        expect(conv.height).to eq(444)
      end
    end
  end
end
