require "spec_helper"

module Sinicum
  module Imaging
    describe Converter do
      let(:conv) do
        clazz = Class.new do
          include Converter

          def initialize(configuration)
            super(configuration)
          end
        end
        clazz
      end

      describe "#device_pixel_size" do
        it "should work without a hires_factor" do
          converter = conv.new("x" => 57)
          expect(converter.send(:device_pixel_size, 57)).to eq(57)
        end

        it "should consider a hires_factor if given" do
          converter = conv.new("x" => 57, "hires_factor" => 2)
          expect(converter.send(:device_pixel_size, 57)).to eq(114)
        end

        it "should consider round a result and always return an integer" do
          converter = conv.new("x" => 57, "hires_factor" => 1.4)
          expect(converter.send(:device_pixel_size, 57)).to eq(80)
          expect(converter.send(:device_pixel_size, 57)).to be_kind_of(Integer)
        end

        it "should work with an empty string" do
          converter = conv.new("x" => 57, "hires_factor" => 2)
          expect(converter.send(:device_pixel_size, '')).to eq('')
        end
      end

      describe "#device_pixel_size_with_srcset" do
        it "should work without a hires_factor" do
          converter = conv.new("x" => 57)
          expect(converter.send(:device_pixel_size_with_srcset, 57, '1.75x')).to eq(100)
        end

        it "should consider a hires_factor if given" do
          converter = conv.new("x" => 57, "hires_factor" => 2)
          expect(converter.send(:device_pixel_size_with_srcset, 57, '2.75x')).to eq(157)
        end

        it "should consider round a result and always return an integer" do
          converter = conv.new("x" => 57, "hires_factor" => 1.4)
          expect(converter.send(:device_pixel_size_with_srcset, 57, '1.5x')).to eq(86)
          expect(converter.send(:device_pixel_size_with_srcset, 57, '1.5x')).to be_kind_of(Integer)
        end

        it "should work with an empty string" do
          converter = conv.new("x" => 57, "hires_factor" => 2)
          expect(converter.send(:device_pixel_size_with_srcset, '', '')).to eq('')
        end
      end

    end
  end
end
