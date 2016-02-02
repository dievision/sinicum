require "spec_helper"
module Sinicum
  module Imaging
    describe ResizeCropConverter do

      it "should require the arguments format, x, y" do
        config = { "format" => "jpeg", "x" => "200", "y" => "300" }
        conv = ResizeCropConverter.new(config)
        config = { "format" => "jpeg", "x" => "200" }
        expect{ conv = ResizeCropConverter.new(config) }.to raise_error(ArgumentError)
        config = { "format" => "jpeg", "y" => "300" }
        expect{ conv = ResizeCropConverter.new(config) }.to raise_error(ArgumentError)
        config = { "x" => "200", "y" => "300" }
        expect{ conv = ResizeCropConverter.new(config) }.to raise_error(ArgumentError)
      end
    end
  end
end
