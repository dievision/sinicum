require "spec_helper"

module Sinicum
  module Imaging
    describe MaxSizeConverter do
      describe "#converted_size" do
        def image(x, y)
          image = double("image")
          image.stub(:width).and_return(x)
          image.stub(:height).and_return(y)
          image
        end

        it "should rescale a landscape image correctly to a landscape format" do
          converter = MaxSizeConverter.new("x" => 57, "y" => 42)
          converter.document = image(192, 110)
          converter.converted_size.should == [57, 33]
        end

        it "should rescale a portrait image correctly to a landscape format" do
          converter = MaxSizeConverter.new("x" => 57, "y" => 42)
          converter.document = image(110, 192)
          converter.converted_size.should == [24, 42]
        end

        it "should rescale a portrait image correctly to a portrait format" do
          converter = MaxSizeConverter.new("x" => 42, "y" => 57)
          converter.document = image(110, 192)
          converter.converted_size.should == [33, 57]
        end

        it "should rescale a landscape image correctly to a portrait format" do
          converter = MaxSizeConverter.new("x" => 42, "y" => 57)
          converter.document = image(192, 110)
          converter.converted_size.should == [42, 24]
        end

        it "should rescale to the same format" do
          converter = MaxSizeConverter.new("x" => 308, "y" => 800)
          converter.document = image(308, 125)
          converter.converted_size.should == [308, 125]
        end

        it "should rescale an image even if the configuration has no 'y' information" do
          converter = MaxSizeConverter.new("x" => 57)
          converter.document = image(192, 110)
          converter.converted_size.should == [57, 33]
        end
      end
    end
  end
end
