require 'spec_helper'

module Sinicum
  describe Imaging do
    it "should return the default converter name" do
      Imaging.default_converter_name.should eq("default")
    end

    it "should return the imaging path" do
      Imaging.path_prefix.should eq("/damfiles")
    end
  end
end
