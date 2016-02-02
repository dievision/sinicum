require 'spec_helper'

module Sinicum
  describe Imaging do
    it "should return the default converter name" do
      expect(Imaging.default_converter_name).to eq("default")
    end
  end
end
