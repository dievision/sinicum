require "spec_helper"

module Sinicum
  module Content
    describe "Content Thread local functionality" do
      it "should return the original content as content data" do
        Aggregator.original_content = "content"
        Aggregator.content_data.should == "content"
      end

      it "should implicitly reset all stacks if original content is called" do
        Aggregator.should_receive(:clean)
        Aggregator.original_content = "original_content"
      end

      it "should return an empty hash if no content node with the respective name exists" do
        Aggregator.original_content = {}
        Aggregator.push_content_node(:no_valid_name) do
          Aggregator.content_data.should == {}
        end
        Aggregator.clean
      end

      it "should clean the stack" do
        Aggregator.original_content = "content"
        Thread.current[:__cms_stack] = "other content"
        Aggregator.clean
        Aggregator.original_content.should.nil?
        Thread.current[:__cms_stack].should.nil?
      end

      it "should push a paragraph name" do
        Aggregator.push_content_node("some_name") do
          Aggregator.content_node.should eq("some_name")
        end
      end

      describe "current content" do
        it "should push current content" do
          Aggregator.original_content = "original"
          in_block = false
          Aggregator.push_current_content("local") do
            Aggregator.content_data.should eq("local")
            in_block = true
          end
          Aggregator.content_data.should eq("original")
          in_block.should be_true
        end
      end

      describe "current page" do
        before(:each) do
          Aggregator.clean
          @original_page = Sinicum::Jcr::Node.new
          @new_page = Sinicum::Jcr::Node.new
          Aggregator.original_content = @original_page
        end

        it "should return the original page if no active page has been set explicitly" do
          Aggregator.active_page.should == @original_page
        end

        it "should push the new content on top of the active page stack" do
          Aggregator.push_active_page(@new_page) do
            Aggregator.active_page.should == @new_page
          end
        end

        it "should restore the active page after the push" do
          Aggregator.push_active_page(@new_page) do
            # nothing
          end
          Aggregator.active_page.should == @original_page
        end

        it "should make the new active page the current content_data object" do
          Aggregator.push_active_page(@new_page) do
            Aggregator.content_data.should == @new_page
          end
        end

        it "should restore the content data object after the push" do
          Aggregator.push_active_page(@new_page) do
            # nothing
          end
          Aggregator.content_data.should == @original_page
        end
      end
    end
  end
end
