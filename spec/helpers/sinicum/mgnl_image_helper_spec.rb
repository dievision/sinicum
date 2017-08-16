# encoding: utf-8
require 'spec_helper'
require 'rexml/document'

module Sinicum
  describe MgnlHelper do
    let(:uuid) { "900985a3-319c-41c6-b327-b46d7fb56d23" }
    let(:image_node) do
      doc = double("document")
      image_node = Jcr::Dam::Image.new
      allow(image_node).to receive(:jcr_path).and_return("/the/path")
      allow(image_node).to receive(:"[]").and_return(nil)
      allow(image_node).to receive(:width).and_return(100)
      allow(image_node).to receive(:height).and_return(50)
      allow(image_node).to receive(:width).with("title").and_return(200)
      allow(image_node).to receive(:height).with("title").and_return(100)
      allow(image_node).to receive(:[]).with(:'jcr:content').and_return(doc)
      allow(image_node).to receive(:jcr_workspace).and_return("dam")
      allow(doc).to receive(:[]).and_return(nil)
      image_node
    end

    context "when an image exists" do
      before(:each) do
        expect(Jcr::Node).to receive(:find_by_uuid).with("dam", uuid).and_return(image_node)
      end

      it "should return the image path" do
        doc = REXML::Document.new(helper.mgnl_img(uuid, renderer: "title"))
        expect(doc.elements["img"].attributes["src"]).to eq(
          "/damfiles/title/the/path-fc308f85a906fce1be5ff58fd2853af5")
      end

      it "should return the image path with source url" do
        allow(helper).to receive(:compute_asset_host).and_return("http://www.dievision.de")
        doc = REXML::Document.new(helper.mgnl_img(uuid, renderer: "title"))
        expect(doc.elements["img"].attributes["src"]).to eq(
          "http://www.dievision.de/damfiles/title/the/path-fc308f85a906fce1be5ff58fd2853af5")
        Rails.configuration.action_controller.asset_host = nil
      end

      it "should return a default renderer if no renderer is given" do
        doc = REXML::Document.new(helper.mgnl_img(uuid))
        expect(doc.elements["img"].attributes["src"]).to eq(
          "/damfiles/default/the/path-fc308f85a906fce1be5ff58fd2853af5")
      end

      it "should create the right alt tag" do
        allow(image_node).to receive(:'[]').with(:subject).and_return("alttext")
        doc = REXML::Document.new(helper.mgnl_img(uuid, renderer: "title"))
        expect(doc.elements["img"].attributes["alt"]).to eq("alttext")
      end

      it "should return an empty alt tag if no subject is given" do
        doc = REXML::Document.new(helper.mgnl_img(uuid, renderer: "title"))
        expect(doc.elements["img"].attributes["alt"]).to eq("")
      end

      it "should return the height and the width attribute" do
        doc = REXML::Document.new(helper.mgnl_img(uuid))
        expect(doc.elements["img"].attributes["width"]).to eq("100")
        expect(doc.elements["img"].attributes["height"]).to eq("50")
      end

      it "should consider the renderer for the image size" do
        doc = REXML::Document.new(helper.mgnl_img(uuid, renderer: "title"))
        expect(doc.elements["img"].attributes["width"]).to eq("200")
        expect(doc.elements["img"].attributes["height"]).to eq("100")
      end

      it "should not render the width if width is false" do
        doc = REXML::Document.new(helper.mgnl_img(uuid, renderer: "title", width: false))
        expect(doc.elements["img"].attributes["width"]).to be_nil
      end

      it "should not render the height if height is false" do
        doc = REXML::Document.new(helper.mgnl_img(uuid, renderer: "title", height: false))
        expect(doc.elements["img"].attributes["height"]).to be_nil
      end

      it "should allow for custom height and width attributes" do
        doc = REXML::Document.new(helper.mgnl_img(
          uuid, renderer: "title", width: "85%", height: "33%"))
        expect(doc.elements["img"].attributes["width"]).to eq("85%")
        expect(doc.elements["img"].attributes["height"]).to eq("33%")
      end

      it "should be possible to add a class attribute" do
        doc = REXML::Document.new(helper.mgnl_img(uuid, class: "someclass"))
        expect(doc.elements["img"].attributes["class"]).to eq("someclass")
      end

      it "should be possible to add a any random attribute attribute" do
        doc = REXML::Document.new(helper.mgnl_img(uuid, :'data-something' => "data"))
        expect(doc.elements["img"].attributes["data-something"]).to eq("data")
      end

      it "should be able to return just the attributes as hash" do
        expect(helper.mgnl_img_attributes(uuid, :'data-something' => "data")).to be_a(Hash)
        expect(helper.mgnl_img_attributes(uuid, :'data-something' => "data")[:'data-something']).to eq("data")
      end
    end

    it "should return nil if no image is found" do
      expect(Jcr::Node).to receive(:find_by_uuid).with("dam", uuid).and_return(nil)
      expect(helper.mgnl_img(uuid, renderer: "title")).to be nil
    end
  end
end
