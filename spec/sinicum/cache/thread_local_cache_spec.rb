require "spec_helper"

module Sinicum::Cache
  describe ThreadLocalCache do
    context "with activated cache" do
      around(:example) do |example|
        ThreadLocalCache.enable!
        example.run
        ThreadLocalCache.disable!
      end

      it "should cache an object" do
        ThreadLocalCache.put("key", "value")

        expect(ThreadLocalCache.get("key")).to eq("value")
      end

      it "should return nil if no object is stored" do
        ThreadLocalCache.put("key", "value")

        expect(ThreadLocalCache.get("another_key")).to be nil
      end

      it "should clear the cache" do
        ThreadLocalCache.put("key", "value")
        ThreadLocalCache.clear

        expect(ThreadLocalCache.get("key")).to be nil
      end

      it "should store an object via the fetch method" do
        ThreadLocalCache.fetch("key") do
          "a value"
        end

        expect(ThreadLocalCache.get("key")).to eq("a value")
      end

      it "should fetch an object via the fetch method" do
        ThreadLocalCache.put("key", "a value")
        result = ThreadLocalCache.fetch("key") do
          "another value"
        end

        expect(result).to eq("a value")
      end

      it "is thread safe" do
        ThreadLocalCache.put("key", "a value")
        result = "something"
        new = Thread.new do
          result = ThreadLocalCache.get("key")
        end
        new.join

        expect(result).to be nil
      end

      it "should be activated" do
        expect(ThreadLocalCache.active?).to be true
      end
    end

    context "with cache disabled" do
      it "should not store anything" do
        ThreadLocalCache.put("key", "value")

        expect(ThreadLocalCache.get("key")).to be nil
      end

      it "produce a cache miss with the fetch method" do
        ThreadLocalCache.put("key", "value")
        result = ThreadLocalCache.fetch("key") do
          "another value"
        end

        expect(result).to eq("another value")
      end
    end
  end
end
