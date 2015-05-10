require 'spec_helper'

module Sinicum
  module Controllers
    describe GlobalStateCache do
      let(:controller) do
        controller = double(:controller)
        request = double(:request)
        controller.stub(:request).and_return(request)
        request.stub(:base_url).and_return("base")
        request.stub(:fullpath).and_return("fullpath")
        controller
      end

      before(:each) do
        Sinicum::Jcr::Cache::GlobalCache.any_instance
          .stub(:current_key).and_return("a11cd0d31248427cbadfd8a7bc51e04e96e4de98")
      end

      it "should return Rails' deployment revision" do
        GlobalStateCache.send(:deploy_revision)
          .should eq("d18187f9016c71e82993c867a90ff9a0554519c9")
      end

      it "should return the cache key" do
        cache = GlobalStateCache.new(controller)
        cache.send(:cache_key).should eq(%w(
          basefullpath
          a11cd0d31248427cbadfd8a7bc51e04e96e4de98
          d18187f9016c71e82993c867a90ff9a0554519c9
        ))
      end
    end
  end
end
