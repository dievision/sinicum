require "spec_helper"

module Sinicum
  module Imaging
    describe MaxSizeConverter do
      describe "#converted_size" do
        def image(x, y)
          image = double("image")
          allow(image).to receive(:width).and_return(x)
          allow(image).to receive(:height).and_return(y)
          image
        end

        it "should rescale a landscape image correctly to a landscape format" do
          converter = MaxSizeConverter.new("x" => 57, "y" => 42)
          converter.document = image(192, 110)
          expect(converter.converted_size).to eq([57, 33])
        end

        it "should rescale a portrait image correctly to a landscape format" do
          converter = MaxSizeConverter.new("x" => 57, "y" => 42)
          converter.document = image(110, 192)
          expect(converter.converted_size).to eq([24, 42])
        end

        it "should rescale a portrait image correctly to a portrait format" do
          converter = MaxSizeConverter.new("x" => 42, "y" => 57)
          converter.document = image(110, 192)
          expect(converter.converted_size).to eq([33, 57])
        end

        it "should rescale a landscape image correctly to a portrait format" do
          converter = MaxSizeConverter.new("x" => 42, "y" => 57)
          converter.document = image(192, 110)
          expect(converter.converted_size).to eq([42, 24])
        end

        it "should rescale to the same format" do
          converter = MaxSizeConverter.new("x" => 308, "y" => 800)
          converter.document = image(308, 125)
          expect(converter.converted_size).to eq([308, 125])
        end

        it "should rescale an image even if the configuration has no 'y' information" do
          converter = MaxSizeConverter.new("x" => 57)
          converter.document = image(192, 110)
          expect(converter.converted_size).to eq([57, 33])
        end
      end
    end
  end
end
