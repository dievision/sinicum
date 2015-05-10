# encoding: utf-8
require 'spec_helper'
require 'rexml/document'

module Sinicum
  describe HelperUtils do
    describe "#object_from_key_or_object" do
      it "should return the node if a node is given as an argument" do
        node = Jcr::Node.new
        helper.send(:object_from_key_or_object, node).should eq(node)
      end

      it "should query for the node if a UUID is given" do
        uuid = "f082dc7a-c23c-42bf-8338-60a6bd5a777b"
        node = Jcr::Node.new
        Jcr::Node.should_receive(:find_by_uuid).with("website", uuid).and_return(node)
        helper.send(:object_from_key_or_object, uuid, "website").should eq(node)
      end

      it "should return the property from the current content data if a symbol is given" do
        begin
          content = { title: "Title" }
          Content::Aggregator.original_content = content
          helper.send(:object_from_key_or_object, :title).should eq("Title")
        ensure
          Content::Aggregator.clean
        end
      end
    end

    describe "#fingerprint_in_asset_path" do
      it "should return when a fingerprint is in the path" do
        helper.send(
          :fingerprint_in_asset_path,
          "/damfiles/image_text_button/home_welcome-841fef0a3e62db91ea8cc9feea6d87a4.jpg"
        ).should be true
      end

      it "should return true when a fingerprint is in the path and the suffix is missing" do
        helper.send(
          :fingerprint_in_asset_path,
          "/damfiles/image_text_button/home_welcome-841fef0a3e62db91ea8cc9feea6d87a4"
        ).should be true
      end

      it "should return false when a fingerprint is not in the path" do
        helper.send(
          :fingerprint_in_asset_path,
          "/damfiles/image_text_button/home_welcome"
        ).should be false
      end
    end
  end
end
