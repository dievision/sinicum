require "spec_helper"

describe "Cache controller" do
  before(:example) do
    # Avoid API calls
    allow(Sinicum::Jcr::Node).to receive(:query).and_return([])
  end

  context "without authentication" do
    it "should return unauthenticated" do
      delete "/_sinicum/cache"

      expect(response.status).to eq(401)
    end

    it "should not change the cache key" do
      cache = Sinicum::Jcr::Cache::GlobalCache.new
      original_cache_key = cache.current_key

      delete "/_sinicum/cache", {}, headers

      expect(cache.current_key).to eq(original_cache_key)
    end
  end

  context "with authentication" do
    let(:auth_key) { "9f791fe4a544432149a1bfdedffde43b" }
    let(:headers) { { "Auth" => auth_key, "CONTENT_TYPE" => "application/json" } }

    around(:example) do |example|
      original_sinicum = Rails.configuration.x.sinicum
      original_auth = Rails.configuration.x.sinicum.admin_auth_key
      Rails.configuration.x.sinicum.admin_auth_key = auth_key
      example.run
      Rails.configuration.x.sinicum.admin_auth_key = original_auth
      Rails.configuration.x.sinicum = original_sinicum
    end

    it "should be a successful request" do
      delete "/_sinicum/cache", {}, headers

      expect(response).to be_success
    end

    it "should change the cache key" do
      cache = Sinicum::Jcr::Cache::GlobalCache.new
      original_cache_key = cache.current_key

      delete "/_sinicum/cache", {}, headers

      expect(cache.current_key).not_to eq(original_cache_key)
    end

    it "should only change the key for the namespace" do
      cache = Sinicum::Jcr::Cache::GlobalCache.new
      original_cache_key = cache.current_key
      original_namespace_key = cache.current_key("a-name")

      delete "/_sinicum/cache", { "namespace" => "a-name" }.to_json, headers

      expect(cache.current_key).to eq(original_cache_key)
      expect(cache.current_key("a-name")).not_to eq(original_namespace_key)
    end

    it "should return cors headers" do
      delete "/_sinicum/cache", {}, headers
    end
  end
end
