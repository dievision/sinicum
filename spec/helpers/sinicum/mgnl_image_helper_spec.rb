# encoding: utf-8
require 'spec_helper'
require 'rexml/document'

module Sinicum
  describe MgnlHelper do
    let(:uuid) { "900985a3-319c-41c6-b327-b46d7fb56d23" }
    let(:image_node) do
      doc = double("document")
      image_node = Jcr::Dam::Image.new
      image_node.stub(:jcr_path).and_return("/the/path")
      image_node.stub(:"[]").and_return(nil)
      image_node.stub(:width).and_return(100)
      image_node.stub(:height).and_return(50)
      image_node.stub(:width).with("title").and_return(200)
      image_node.stub(:height).with("title").and_return(100)
      image_node.stub(:[]).with(:'jcr:content').and_return(doc)
      doc.stub(:[]).and_return(nil)
      image_node
    end

    context "when an image exists" do
      before(:each) do
        Jcr::Node.should_receive(:find_by_uuid).with("dam", uuid).and_return(image_node)
      end

      it "should return the image path" do
        doc = REXML::Document.new(helper.mgnl_img(uuid, renderer: "title"))
        doc.elements["img"].attributes["src"].should eq(
          "/damfiles/title/the/path-fc308f85a906fce1be5ff58fd2853af5")
      end

      it "should return the image path with source url" do
        helper.stub(:compute_asset_host).and_return("http://www.dievision.de")
        doc = REXML::Document.new(helper.mgnl_img(uuid, renderer: "title"))
        doc.elements["img"].attributes["src"].should eq(
          "http://www.dievision.de/damfiles/title/the/path-fc308f85a906fce1be5ff58fd2853af5")
        Rails.configuration.action_controller.asset_host = nil
      end

      it "should return a default renderer if no renderer is given" do
        doc = REXML::Document.new(helper.mgnl_img(uuid))
        doc.elements["img"].attributes["src"].should eq(
          "/damfiles/default/the/path-fc308f85a906fce1be5ff58fd2853af5")
      end

      it "should create the right alt tag" do
        image_node.stub(:'[]').with(:subject).and_return("alttext")
        doc = REXML::Document.new(helper.mgnl_img(uuid, renderer: "title"))
        doc.elements["img"].attributes["alt"].should eq("alttext")
      end

      it "should return an empty alt tag if no subject is given" do
        doc = REXML::Document.new(helper.mgnl_img(uuid, renderer: "title"))
        doc.elements["img"].attributes["alt"].should eq("")
      end

      it "should return the height and the width attribute" do
        doc = REXML::Document.new(helper.mgnl_img(uuid))
        doc.elements["img"].attributes["width"].should eq("100")
        doc.elements["img"].attributes["height"].should eq("50")
      end

      it "should consider the renderer for the image size" do
        doc = REXML::Document.new(helper.mgnl_img(uuid, renderer: "title"))
        doc.elements["img"].attributes["width"].should eq("200")
        doc.elements["img"].attributes["height"].should eq("100")
      end

      it "should not render the width if width is false" do
        doc = REXML::Document.new(helper.mgnl_img(uuid, renderer: "title", width: false))
        doc.elements["img"].attributes["width"].should be_nil
      end

      it "should not render the height if height is false" do
        doc = REXML::Document.new(helper.mgnl_img(uuid, renderer: "title", height: false))
        doc.elements["img"].attributes["height"].should be_nil
      end

      it "should allow for custom height and width attributes" do
        doc = REXML::Document.new(helper.mgnl_img(
          uuid, renderer: "title", width: "85%", height: "33%"))
        doc.elements["img"].attributes["width"].should eq("85%")
        doc.elements["img"].attributes["height"].should eq("33%")
      end

      it "should be possible to add a class attribute" do
        doc = REXML::Document.new(helper.mgnl_img(uuid, class: "someclass"))
        doc.elements["img"].attributes["class"].should eq("someclass")
      end

      it "should be possible to add a any random attribute attribute" do
        doc = REXML::Document.new(helper.mgnl_img(uuid, :'data-something' => "data"))
        doc.elements["img"].attributes["data-something"].should eq("data")
      end
    end

    it "should return nil if no image is found" do
      Jcr::Node.should_receive(:find_by_uuid).with("dam", uuid).and_return(nil)
      helper.mgnl_img(uuid, renderer: "title").should be nil
    end
  end
end
