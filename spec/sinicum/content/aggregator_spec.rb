require "spec_helper"

module Sinicum
  module Content
    describe "Content Thread local functionality" do
      it "should return the original content as content data" do
        Aggregator.original_content = "content"
        expect(Aggregator.content_data).to  eq("content")
      end

      it "should implicitly reset all stacks if original content is called" do
        expect(Aggregator).to receive(:clean)
        Aggregator.original_content = "original_content"
      end

      it "should return an empty hash if no content node with the respective name exists" do
        Aggregator.original_content = {}
        Aggregator.push_content_node(:no_valid_name) do
          expect(Aggregator.content_data).to eq({})
        end
        Aggregator.clean
      end

      it "should clean the stack" do
        Aggregator.original_content = "content"
        Thread.current[:__cms_stack] = "other content"
        Aggregator.clean
        expect(Aggregator.original_content).to be_nil
        expect(Thread.current[:__cms_stack]).to be_nil
      end

      it "should push a paragraph name" do
        Aggregator.push_content_node("some_name") do
          expect(Aggregator.content_node).to eq("some_name")
        end
      end

      describe "current content" do
        it "should push current content" do
          Aggregator.original_content = "original"
          in_block = false
          Aggregator.push_current_content("local") do
            expect(Aggregator.content_data).to eq("local")
            in_block = true
          end
          expect(Aggregator.content_data).to eq("original")
          expect(in_block).to be_truthy
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
          expect(Aggregator.active_page).to eq(@original_page)
        end

        it "should push the new content on top of the active page stack" do
          Aggregator.push_active_page(@new_page) do
            expect(Aggregator.active_page).to eq(@new_page)
          end
        end

        it "should restore the active page after the push" do
          Aggregator.push_active_page(@new_page) do
            # nothing
          end
          expect(Aggregator.active_page).to eq(@original_page)
        end

        it "should make the new active page the current content_data object" do
          Aggregator.push_active_page(@new_page) do
            expect(Aggregator.content_data).to eq(@new_page)
          end
        end

        it "should restore the content data object after the push" do
          Aggregator.push_active_page(@new_page) do
            # nothing
          end
          expect(Aggregator.content_data).to eq(@original_page)
        end
      end
    end
  end
end
