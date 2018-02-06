require 'spec_helper'

module Sinicum
  module Jcr
    module Cache
      describe GlobalCache do
        it "should return the current key" do
          expect(GlobalCache.new.current_key).to match(/[a-f0-9]{32}/)
        end

        it "should return the same key for multiple requests" do
          key = GlobalCache.new.current_key

          expect(GlobalCache.new.current_key).to eq(key)
        end

        it "should reset a key" do
          key = GlobalCache.new.current_key
          GlobalCache.new.reset_key

          expect(GlobalCache.new.current_key).not_to eq(key)
        end

        it "should have a different key for a different namespace" do
          cache = GlobalCache.new
          global_key = cache.current_key
          namespace_key = cache.current_key("www.somenamespace.com")

          expect(global_key).not_to eq(namespace_key)
        end

        it "should not reset the global namespace if a namespace is being reset" do
          cache = GlobalCache.new
          global_key = cache.current_key
          namespace_key = cache.current_key("www.somenamespace.com")

          cache.reset_key("www.somenamespace.com")

          expect(cache.current_key).to eq(global_key)
          expect(cache.current_key("www.somenamespace.com")).not_to eq(namespace_key)
        end

        it "should reset the namespace key if the global key is reset" do
          cache = GlobalCache.new
          global_key = cache.current_key
          namespace_key = cache.current_key("www.somenamespace.com")

          cache.reset_key()

          expect(cache.current_key).not_to eq(global_key)
          expect(cache.current_key("www.somenamespace.com")).not_to eq(namespace_key)
        end
      end
    end
  end
end
