# encoding: utf-8
require 'spec_helper'
require 'rexml/document'

module Sinicum
  describe HelperUtils do
    describe "#object_from_key_or_object" do
      it "should return the node if a node is given as an argument" do
        node = Jcr::Node.new
        expect(helper.send(:object_from_key_or_object, node)).to eq(node)
      end

      it "should query for the node if a UUID is given" do
        uuid = "f082dc7a-c23c-42bf-8338-60a6bd5a777b"
        node = Jcr::Node.new
        expect(Jcr::Node).to receive(:find_by_uuid).with("website", uuid).and_return(node)
        expect(helper.send(:object_from_key_or_object, uuid, "website")).to eq(node)
      end

      it "should return the property from the current content data if a symbol is given" do
        begin
          content = { title: "Title" }
          Content::Aggregator.original_content = content
          expect(helper.send(:object_from_key_or_object, :title)).to eq("Title")
        ensure
          Content::Aggregator.clean
        end
      end
    end

    describe "#fingerprint_in_asset_path" do
      it "should return when a fingerprint is in the path" do
        expect(helper.send(
          :fingerprint_in_asset_path,
          "/damfiles/image_text_button/home_welcome-841fef0a3e62db91ea8cc9feea6d87a4.jpg"
        )).to be true
      end

      it "should return true when a fingerprint is in the path and the suffix is missing" do
        expect(helper.send(
          :fingerprint_in_asset_path,
          "/damfiles/image_text_button/home_welcome-841fef0a3e62db91ea8cc9feea6d87a4"
        )).to be true
      end

      it "should return false when a fingerprint is not in the path" do
        expect(helper.send(
          :fingerprint_in_asset_path,
          "/damfiles/image_text_button/home_welcome"
        )).to be false
      end
    end

    describe "#add_srcset" do

      test_config = File.join(File.dirname(__FILE__), "../../fixtures/imaging.yml")
      let(:config) { Sinicum::Imaging::Config.configure(test_config) }

      it "should add srcset tags to attributes" do
        tag_with_srcset = {
          :src=>"/damfiles/etc/pp/hero-teaser-cruises-1e531d3c7476f916d42215fd2f829839.jpg",
          :alt=>"hero-teaser-cruises", :width=>1920, :height=>480, :class=>"slide-img",
          :srcset=>"/damfiles/etc/pp/hero-teaser-cruises_050-1e531d3c7476f916d42215fd2f829839.jpg 0.5x, /damfiles/etc/pp/hero-teaser-cruises_150-1e531d3c7476f916d42215fd2f829839.jpg 1.5x, /damfiles/etc/pp/hero-teaser-cruises_175-1e531d3c7476f916d42215fd2f829839.jpg 1.75x, /damfiles/etc/pp/hero-teaser-cruises_200-1e531d3c7476f916d42215fd2f829839.jpg 2x"}
        allow(Sinicum::Imaging::Config).to receive(:read_configuration).and_return(config)
        expect(helper.send(
          :add_srcset,
          {:src=>"/damfiles/etc/pp/hero-teaser-cruises-1e531d3c7476f916d42215fd2f829839.jpg", :alt=>"hero-teaser-cruises", :width=>1920, :height=>480, :class=>"slide-img"}
        )).to eq(tag_with_srcset)
      end

       it "should not add srcset tags to attributes" do
        img_tag = {
          :src=>"/damfiles/etc/pp/hero-teaser-cruises-1e531d3c7476f916d42215fd2f829839.jpg",
          :alt=>"hero-teaser-cruises", :width=>1920, :height=>480, :class=>"slide-img"
        }
        allow(helper).to receive(:loaded_srcset_options).and_return([])
        expect(helper.send(
          :add_srcset,
          {:src=>"/damfiles/etc/pp/hero-teaser-cruises-1e531d3c7476f916d42215fd2f829839.jpg", :alt=>"hero-teaser-cruises", :width=>1920, :height=>480, :class=>"slide-img"}
        )).to eq(img_tag)
      end
    end

  end
end
