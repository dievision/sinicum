require 'spec_helper'

module Sinicum
  module Controllers
    describe GlobalStateCache do
      let(:controller) do
        controller = double(:controller)
        request = double(:request)
        allow(controller).to receive(:request).and_return(request)
        allow(request).to receive(:base_url).and_return("base")
        allow(request).to receive(:fullpath).and_return("fullpath")
        allow(request).to receive(:path).and_return("/dievision")
        controller
      end

      before(:each) do
        allow_any_instance_of(Sinicum::Jcr::Cache::GlobalCache)
          .to receive(:current_key).and_return("a11cd0d31248427cbadfd8a7bc51e04e96e4de98")
        allow_any_instance_of(Sinicum::Jcr::Cache::SiteCache)
          .to receive(:current_key_for).and_return("a11cd0d31248427cbadfd8a7bc51e04e96e4de98")
      end

      it "should return Rails' deployment revision" do
        expect(GlobalStateCache.send(:deploy_revision))
          .to eq("d18187f9016c71e82993c867a90ff9a0554519c9")
      end

      it "should return the cache key" do
        cache = GlobalStateCache.new(controller)
        expect(cache.send(:cache_key)).to eq(%w(
          basefullpath
          a11cd0d31248427cbadfd8a7bc51e04e96e4de98
          d18187f9016c71e82993c867a90ff9a0554519c9
          ))
      end
    end
  end
end
