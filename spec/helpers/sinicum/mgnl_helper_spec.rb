# encoding: utf-8
require 'spec_helper'
require 'rexml/document'

module Sinicum
  describe MgnlHelper do
    describe "#mgnl_path" do
      let(:node) do
        node = Jcr::Node.new
        node.stub(:jcr_path).and_return("/the/path")
        node
      end

      let(:document) do
        node = Jcr::Dam::Document.new
        node.stub(:jcr_path).and_return("/the/path")
        doc = double("document")
        node.stub(:[]).and_return(nil)
        node.stub(:[]).with(:'jcr:content').and_return(doc)
        doc.stub(:[]).and_return(nil)
        node
      end

      it "should return a node's path" do
        helper.mgnl_path(node).should eq("/the/path")
      end

      it "should return the right path for a UUID string" do
        Jcr::Node.should_receive(:find_by_uuid)
          .with("website", "900985a3-319c-41c6-b327-b46d7fb56d23")
          .and_return(node)

        helper.mgnl_path("900985a3-319c-41c6-b327-b46d7fb56d23").should eq("/the/path")
      end

      it "should handle other repositories than the website" do
        Jcr::Node.should_receive(:find_by_uuid)
          .with("dam", "900985a3-319c-41c6-b327-b46d7fb56d23")
          .and_return(node)

        helper.mgnl_path("900985a3-319c-41c6-b327-b46d7fb56d23", workspace: "dam")
          .should eq("/the/path")
      end

      it "should ignore the renderer when the node is not a document" do
        helper.mgnl_path(node, renderer: "video").should eq("/the/path")
      end

      it "should work with the renderer when the node is a document" do
        helper.mgnl_path(document, renderer: "video").should eq(
          "/damfiles/video/the/path-fc308f85a906fce1be5ff58fd2853af5")
      end

      it "should return a string if the path given is a string" do
        helper.mgnl_path("/some/path").should eq("/some/path")
      end

      it "should return a string if the property that defines the link returns a string" do
        Jcr::Node.should_receive(:find_by_uuid)
          .with("website", "900985a3-319c-41c6-b327-b46d7fb56d23")
          .and_return("/some/path")
        helper.mgnl_path("900985a3-319c-41c6-b327-b46d7fb56d23", workspace: "website")
          .should eq("/some/path")
      end
    end

    describe "#mgnl_content_data" do
      it "should return the current content data from the aggregator" do
        content = double(:content)
        Content::Aggregator.should_receive(:content_data).and_return(content)
        helper.mgnl_content_data.should eq(content)
      end
    end

    describe "#mgnl_link" do
      it "should pass through a string as a link" do
        doc = REXML::Document.new(helper.mgnl_link("/path/to/link"))
        doc.elements["a"].attributes["href"].should eq("/path/to/link")
      end

      it "should pass through a string as a link when a block is given" do
        doc = REXML::Document.new(helper.mgnl_link("/path/to/link") { "something" })
        doc.elements["a"].attributes["href"].should eq("/path/to/link")
      end
    end

    describe "#push" do
      after(:each) do
        Content::Aggregator.clean
      end

      it "should push content" do
        node = Jcr::Node.new
        block_called = false
        helper.mgnl_push(node) do
          block_called = true
          Content::Aggregator.content_data.should eq(node)
        end
        block_called.should be true
        Content::Aggregator.content_data.should be nil
      end

      it "should not yield if no content is found"

      it "should resolve a UUID if a UUID is returned"
    end

    describe "#mgnl_original_content" do
      it "should fetch the original content"
    end

    describe "#mgnl_out" do
      let(:node) do
        node = Jcr::Node.new
        node.stub(:title).and_return("The title")
        node
      end

      before(:each) do
        Content::Aggregator.stub(:original_content).and_return(node)
      end

      it "should output a property" do
        helper.mgnl_out(:title).should eq("The title")
      end

      it "should output an empty string if the property does not exist" do
        helper.mgnl_out(:some_unknown_attribute).should eq("")
      end
    end

    describe "#mgnl_meta" do
      it "should display a title" do
        Sinicum::Content::Aggregator.push(title: "My Headline") do
          result = REXML::Document.new("<div>" + helper.mgnl_meta + "</div>")
          result.root.elements['title'].size.should eq(1)
        end
      end

      it "should remove tags from the title" do
        Sinicum::Content::Aggregator.push(title: "my <b>bold</b> title") do
          result = REXML::Document.new("<div>" + helper.mgnl_meta + "</div>")
          result.root.elements['title'].size.should eq(1)
          result.root.elements['title'].first.to_s.should eq("my bold title")
        end
      end

      it "should prefer meta_title for the title" do
        Sinicum::Content::Aggregator.push(meta_title: "Preferred title") do
          result = REXML::Document.new("<div>" + helper.mgnl_meta + "</div>")
          result.root.elements['title'].first.to_s.should eq("Preferred title")
        end
      end

      it "should add a prefix for the title" do
        Sinicum::Content::Aggregator.push(title: "My Headline") do
          result = REXML::Document.new("<div>" +
            helper.mgnl_meta(title_prefix: "The Prefix") + "</div>")
          result.root.elements['title'].first.to_s.should eq("The Prefix – My Headline")
        end
      end

      it "should add a suffix for the title" do
        Sinicum::Content::Aggregator.push(title: "My Headline") do
          result = REXML::Document.new("<div>" +
            helper.mgnl_meta(title_suffix: "The Suffix") + "</div>")
          result.root.elements['title'].first.to_s.should eq("My Headline – The Suffix")
        end
      end

      it "should not add a delimiter after the prefix if no title is present" do
        Sinicum::Content::Aggregator.push({}) do
          result = REXML::Document.new("<div>" +
            helper.mgnl_meta(title_prefix: "The Prefix") + "</div>")
          result.root.elements['title'].first.to_s.should eq("The Prefix")
        end
      end

      it "should not add a delimiter before the suffix if no title is present" do
        Sinicum::Content::Aggregator.push({}) do
          result = REXML::Document.new("<div>" +
            helper.mgnl_meta(title_prefix: "The Suffix") + "</div>")
          result.root.elements['title'].first.to_s.should eq("The Suffix")
        end
      end

      it "should not add an emtpy title attribute if no title is defined" do
        Sinicum::Content::Aggregator.push({}) do
          result = REXML::Document.new("<div>" + helper.mgnl_meta + "</div>")
          result.root.elements['title'].first.to_s.should eq("")
        end
      end

      it "should display a desciption tag" do
        Sinicum::Content::Aggregator.push(meta_description: "A Description") do
          result = REXML::Document.new("<div>" + helper.mgnl_meta + "</div>")
          result.root.elements["meta[@name = 'description']"].attributes["content"]
            .should eq("A Description")
        end
      end

      it "should not display a desciption tag if no description is given" do
        result = REXML::Document.new("<div>" + helper.mgnl_meta + "</div>")
        result.root.elements["meta[@name = 'description']"].should be nil
      end

      it "should display a keywords tag" do
        Sinicum::Content::Aggregator.push(meta_keywords: "some keyowrds") do
          result = REXML::Document.new("<div>" + helper.mgnl_meta + "</div>")
          result.root.elements["meta[@name = 'keywords']"].attributes["content"]
            .should eq("some keyowrds")
        end
      end

      it "should not display a keywords tag if no description is given" do
        result = REXML::Document.new("<div>" + helper.mgnl_meta + "</div>")
        result.root.elements["meta[@name = 'keywords']"].should be nil
      end

      it "should display 'robots: noindex,nofollow' tag" do
        Sinicum::Content::Aggregator.push(meta_noindex: true) do
          result = REXML::Document.new("<div>" + helper.mgnl_meta + "</div>")
          result.root.elements["meta[@name = 'robots']"].attributes["content"].should =~ /noindex/
          result.root.elements["meta[@name = 'robots']"].attributes["content"].should =~ /nofollow/
        end
      end

      it "should display no 'robots' tag by default" do
        result = REXML::Document.new("<div>" + helper.mgnl_meta + "</div>")
        result.root.elements["meta[@name = 'robots']"].should be nil
      end

      it "should display a language tag" do
        result = REXML::Document.new("<div>" + helper.mgnl_meta + "</div>")
        result.root.elements["meta[@name = 'language']"].attributes["content"]
          .should eq(I18n.locale.to_s)
      end

      it "should display the content type tag" do
        result = REXML::Document.new("<div>" + helper.mgnl_meta + "</div>")
        result.root.elements["meta[@http-equiv = 'content-type']"].attributes["content"]
          .should eq("text/html; charset=utf-8")
      end

      it "should be html_safe" do
        helper.mgnl_meta.should be_html_safe
      end
    end

    describe "#mgnl_navigation" do
      let(:handler) { double "handler" }
      let(:el1) { double("el1") }
      let(:el2) { double("el2") }
      let(:elements) { [el1, el2] }

      describe "path based" do
        before(:each) do
          Navigation::NavigationHandler.should_receive(:children).with("/de", 3)
            .and_return(handler)
          handler.should_receive(:elements).and_return(elements)
        end

        it "should the children navigation handler" do
          helper.mgnl_navigation("/de", :children, depth: 3)
        end

        it "should yield the block" do
          expect { |arg|  elements.each(&arg) }.to yield_successive_args(el1, el2)
          helper.mgnl_navigation("/de", :children, depth: 3) { |nav| }
        end

        it "should retun the elements if no block given" do
          result = helper.mgnl_navigation("/de", :children, depth: 3)
          result.size.should eq(2)
        end
      end

      describe "node based" do
        let(:node) { double("node") }

        before(:each) do
          Navigation::NavigationHandler.should_receive(:children).with(node, 3)
            .and_return(handler)
          handler.should_receive(:elements).and_return(elements)
        end

        it "should the children navigation handler" do
          helper.mgnl_navigation(node, :children, depth: 3)
        end
      end

      describe "path based parents" do
        before(:each) do
          Navigation::NavigationHandler.should_receive(:parents).with("/de")
            .and_return(handler)
          handler.should_receive(:elements).and_return(elements)
        end

        it "should the children navigation handler" do
          helper.mgnl_navigation("/de", :parents)
        end

        it "should yield the block" do
          expect { |arg|  elements.each(&arg) }.to yield_successive_args(el1, el2)
          helper.mgnl_navigation("/de", :parents) { |nav| }
        end

        it "should return the elements if no block given" do
          elements = helper.mgnl_navigation("/de", :parents)
          elements.size.should eq(2)
        end
      end
    end
  end
end
