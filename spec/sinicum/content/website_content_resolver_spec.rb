require 'spec_helper'

module Sinicum
  module Content
    describe WebsiteContentResolver do
      it "should fetch the content matching the path" do
        node = double(:node)
        Sinicum::Jcr::Node.should_receive(:find_by_path).with(:website, "/home").and_return(node)
        result = WebsiteContentResolver.find_for_path("/home")
        result.should eq(node)
      end
    end
  end
end
