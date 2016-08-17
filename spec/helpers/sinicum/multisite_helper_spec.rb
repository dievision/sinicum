require 'spec_helper'

module Sinicum
  describe MultisiteHelper do
    before(:example) do
      session[:multisite_root] = "/sinicum"
    end

    it "should transform a root path" do
      path = "/sinicum"
      expect(helper.url_for(path)).to eq("/")

      path = "/sinicum/"
      expect(helper.url_for(path)).to eq("/")
    end

    it "should transform a root path followed by more" do
      path = "/sinicum/magnolia"
      expect(helper.url_for(path)).to eq("/magnolia")

      path = "/sinicum/magnolia/"
      expect(helper.url_for(path)).to eq("/magnolia/")
    end

    it "should not transform a not matching path" do
      path = "/magnolia/sinicum"
      expect(helper.url_for(path)).to eq("/magnolia/sinicum")
    end
  end
end
