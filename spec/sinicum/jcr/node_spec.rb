# encoding: utf-8
require 'spec_helper'

module Sinicum
  module Jcr
    describe Node do
      context "should behave like an ActiveModel object" do
        require 'test/unit/assertions'
        require 'active_model/lint'
        include Test::Unit::Assertions
        include ActiveModel::Lint::Tests

        before(:each) do
          @model = Node.new
        end

        #unless Rails.version =~ /^4\.1\./
          ActiveModel::Lint::Tests.public_instance_methods.map { |m| m.to_s }.grep(/^test/)
            .each do |m|
            example m.gsub("_", " ") do
              send(m)
            end
          end

          it "should expose a singular and human name" do
            @model.class.model_name.singular.should eq("sinicum_jcr_node")
            @model.class.model_name.human.should eq("Node")
          end
        #end

        it "should use i18n for model_name.human" do
          begin
            I18n.backend.store_translations(
              I18n.locale,
              activemodel: {
                models: {
                  :'sinicum/jcr/node' => "A node name"
                }
              })
            @model.class.model_name.human.should eq("A node name")
          ensure
            I18n.reload!
          end
        end
      end

      describe "basic properties after JSON initialization" do
        let(:api_response) do
          File.read(File.dirname(__FILE__) + "/../../fixtures/api/content_mgnl5.json")
        end
        let(:json_response) { MultiJson.load(api_response) }
        let(:subject) { Node.new(json_response: json_response.first) }

        it "should have correct attributes" do
          subject.uuid.should eq("684af75b-0504-467e-92ce-bea998cc8d8b")
          subject.jcr_path.should eq("/home")
          subject.jcr_name.should eq("home")
          subject.jcr_primary_type.should eq("mgnl:page")
          subject.jcr_super_types.should eq(
            [
              "mix:created", "mix:referenceable", "nt:base", "nt:hierarchyNode",
              "mgnl:activatable", "mgnl:content", "mgnl:created", "mgnl:lastModified",
              "mgnl:renderable", "mgnl:versionable"
            ])
          subject.jcr_mixin_node_types.should eq([])
          subject.jcr_workspace.should eq("website")
          subject.jcr_depth.should eq(1)

          unless defined?(JRUBY_VERSION)
            subject.created_at.should eq(DateTime.new(2014, 3, 16, 14, 6, 17.666, "+01:00"))
            subject.updated_at.should eq(DateTime.new(2014, 3, 18, 15, 57, 51.329, "+01:00"))
          end

          subject.mgnl_template.should eq("themodule:pages/appplication")
          subject.mgnl_created_by.should eq("superuser")
        end

        it "should translate the child nodes" do
          subject[:photo].should be_a Sinicum::Jcr::Dam::Document
        end
      end

      describe "handling of properties" do
        let(:api_response) do
          File.read(File.dirname(__FILE__) + "/../../fixtures/api/homepage.json")
        end
        let(:json_response) { MultiJson.load(api_response) }
        let(:subject) { Node.new(json_response: json_response.first) }

        it "should return the correct title" do
          subject[:title].should eq("Shure: Mikrofone, Funkmikrofone, Ohrhörer")
          subject[:boolean_true_test].should be true
        end

        it "should be possible to use symbol and string keys interchangeably" do
          subject[:title].should eq("Shure: Mikrofone, Funkmikrofone, Ohrhörer")
          subject["title"].should eq("Shure: Mikrofone, Funkmikrofone, Ohrhörer")
        end

        it "should resolve mulitvalue properties correctly" do
          subject[:multivalue_test].should eq(["Value1", "Value2"])
        end
      end

      describe "handling of child nodes" do
        let(:api_response) do
          File.read(File.dirname(__FILE__) + "/../../fixtures/api/homepage.json")
        end
        let(:json_response) { MultiJson.load(api_response) }
        let(:subject) { Node.new(json_response: json_response.first) }

        it "should return a child node and resolve an array" do
          children = subject[:orc_13]
          children.should be_kind_of(Array)
        end

        it "should return the correct child node" do
          children = subject[:orc_13]
          children.first.jcr_path.should eq("/home/orc_13/0")
        end

        it "should return nodes in multiple steps" do
          picture_teaser = subject[:orc_13].first[:picture_teaser_items].first
          picture_teaser[:link_text].should eq("more")
        end

        it "should return non-array child nodes" do
          picture_teaser = subject[:orc_13].first[:picture_teaser_items].first
          text_files_node = picture_teaser[:text_files]
          text_files_node.should be_kind_of(Node)
          text_files_node.jcr_path.should eq("/home/orc_13/0/picture_teaser_items/0/text_files")
        end

        it "should be possible to call a node multiple times" do
          children = subject[:orc_13]
          children.should_not be_nil
          subject[:orc_13].should eq(children)
        end
      end

      describe "parent handling" do
        let(:api_response) do
          File.read(File.dirname(__FILE__) + "/../../fixtures/api/homepage_parent.json")
        end
        let(:api_response2) do
          File.read(File.dirname(__FILE__) + "/../../fixtures/api/homepage.json")
        end
        let(:json_response) { MultiJson.load(api_response) }
        let(:subject) { Node.new(json_response: json_response) }

        it "should return its parent node as an Array" do
          body = { body: "should not be triggered because of cache" }
          stub_request(:get, "http://content.dievision.de/sinicum-rest/website/home/orc_13")
            .to_return(body: api_response, headers: { "Content-Type" => "application/json" })
            .times(1).then.to_return(body)
          stub_request(:get, "http://content.dievision.de/sinicum-rest/website/home")
            .to_return(body: api_response2, headers: { "Content-Type" => "application/json" })

          node = subject[0]
          node.parent.uuid.should eq(subject.uuid)
          node.parent.parent.uuid.should eq('21cbc762-bdcd-4520-9eff-1928986fb419')
        end
      end

      describe "Type conversion" do
        describe "date conversion" do
          it "should properly convert a iso 8601 time string" do
            time = subject.send(:jcr_time_string_to_datetime, "2010-04-13T09:35:01.322+02:00")
            time.year.should eq(2010)
            time.month.should eq(4)
            time.day.should eq(13)
            time.hour.should eq(9)
            time.minute.should eq(35)
            time.second.should eq(1)
            time.zone.should eq("+02:00")
          end

          it "should return the original string if it is not an iso8601 format" do
            time = subject.send(:jcr_time_string_to_datetime, "2010-04-13F09:35:01.322+02:00")
            time.should eq("2010-04-13F09:35:01.322+02:00")
          end

          it "should handle null values" do
            time = subject.send(:jcr_time_string_to_datetime, nil)
            time.should be nil
          end

          it "should convert Magnolia's Date notation: e.g. 2013-06-05T22:00:00.000Z" do
            time = subject.send(:jcr_time_string_to_datetime, "2013-06-05T22:00:00.000Z")
            time.year.should eq(2013)
            time.month.should eq(6)
            time.day.should eq(6)
          end

          it "should convert Magnolia's Date notation to a date object" do
            time = subject.send(:jcr_time_string_to_datetime, "2013-06-05T22:00:00.000Z")
            time.should be_a(Date)
          end
        end

        describe "boolean conversion" do
          it "should not touch strings" do
            value = subject.send(:mgnl_boolean_string_to_boolean, "Some string")
            value.should eq("Some string")
          end

          it "should convert true values" do
            value = subject.send(:mgnl_boolean_string_to_boolean, "true")
            value.should be true
          end

          it "should convert false values" do
            value = subject.send(:mgnl_boolean_string_to_boolean, "false")
            value.should be false
          end
        end
      end

      describe "persistence" do
        it "should not be persisted as a new node" do
          node = Node.new
          node.should_not be_persisted
        end

        it "should be persisted if constructed from an api response" do
          api_response = File.read(File.dirname(__FILE__) + "/../../fixtures/api/homepage.json")
          node = Node.new(json_response: api_response)
          node.should be_persisted
        end
      end

      describe "initialize from hash" do
        it "should set a property" do
          node = Node.new(name: "A name")
          node[:name].should eq("A name")
        end

        it "should not be possible to set 'forbidden' JCR properties" do
          Node::PROHIBITED_JCR_PROPERTIES.each do |prop|
            expect { Node.new(prop => "value") }.to raise_error
          end
        end

        it "should not be possible to set 'forbidden' Manglia properties" do
          Node::PROHIBITED_MGNL_PROPERTIES.each do |prop|
            expect { Node.new(prop => "value") }.to raise_error
          end
        end

        it "should directly set allowed JCR properties" do
          Node::SETABLE_JCR_PROPERTIES.each do |prop|
            node = Node.new(prop => "value")
            node.send(prop).should eq("value")
          end
        end

        it "should should not set a hash-based value for a directly allowed JCR property" do
          Node::SETABLE_JCR_PROPERTIES.each do |prop|
            node = Node.new(prop => "value")
            node[prop].should be_nil
          end
        end

        it "should directly set allowed Magnolia properties" do
          Node::SETABLE_MGNL_PROPERTIES.each do |prop|
            node = Node.new(prop => "value")
            node.send(prop).should eq("value")
          end
        end

        it "should should not set a hash-based value for a directly allowed Magnolia property" do
          Node::SETABLE_MGNL_PROPERTIES.each do |prop|
            node = Node.new(prop => "value")
            node[prop].should be_nil
          end
        end
      end
    end
  end
end
