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
            expect(@model.class.model_name.singular).to eq("sinicum_jcr_node")
            expect(@model.class.model_name.human).to eq("Node")
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
            expect(@model.class.model_name.human).to eq("A node name")
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
          expect(subject.uuid).to eq("684af75b-0504-467e-92ce-bea998cc8d8b")
          expect(subject.jcr_path).to eq("/home")
          expect(subject.jcr_name).to eq("home")
          expect(subject.jcr_primary_type).to eq("mgnl:page")
          expect(subject.jcr_super_types).to eq(
            [
              "mix:created", "mix:referenceable", "nt:base", "nt:hierarchyNode",
              "mgnl:activatable", "mgnl:content", "mgnl:created", "mgnl:lastModified",
              "mgnl:renderable", "mgnl:versionable"
            ])
          expect(subject.jcr_mixin_node_types).to eq([])
          expect(subject.jcr_workspace).to eq("website")
          expect(subject.jcr_depth).to eq(1)

          unless defined?(JRUBY_VERSION)
            expect(subject.created_at).to eq(DateTime.new(2014, 3, 16, 14, 6, 17.666, "+01:00"))
            expect(subject.updated_at).to eq(DateTime.new(2014, 3, 18, 15, 57, 51.329, "+01:00"))
          end

          expect(subject.mgnl_template).to eq("themodule:pages/appplication")
          expect(subject.mgnl_created_by).to eq("superuser")
        end

        it "should translate the child nodes" do
          expect(subject[:photo]).to be_a Sinicum::Jcr::Dam::Document
        end
      end

      describe "handling of properties" do
        let(:api_response) do
          File.read(File.dirname(__FILE__) + "/../../fixtures/api/homepage.json")
        end
        let(:json_response) { MultiJson.load(api_response) }
        let(:subject) { Node.new(json_response: json_response.first) }

        it "should return the correct title" do
          expect(subject[:title]).to eq("Shure: Mikrofone, Funkmikrofone, Ohrhörer")
          expect(subject[:boolean_true_test]).to be true
        end

        it "should be possible to use symbol and string keys interchangeably" do
          expect(subject[:title]).to eq("Shure: Mikrofone, Funkmikrofone, Ohrhörer")
          expect(subject["title"]).to eq("Shure: Mikrofone, Funkmikrofone, Ohrhörer")
        end

        it "should resolve mulitvalue properties correctly" do
          expect(subject[:multivalue_test]).to eq(["Value1", "Value2"])
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
          expect(children).to be_kind_of(Array)
        end

        it "should return the correct child node" do
          children = subject[:orc_13]
          expect(children.first.jcr_path).to eq("/home/orc_13/0")
        end

        it "should return nodes in multiple steps" do
          picture_teaser = subject[:orc_13].first[:picture_teaser_items].first
          expect(picture_teaser[:link_text]).to eq("more")
        end

        it "should return non-array child nodes" do
          picture_teaser = subject[:orc_13].first[:picture_teaser_items].first
          text_files_node = picture_teaser[:text_files]
          expect(text_files_node).to be_kind_of(Node)
          expect(text_files_node.jcr_path).to eq("/home/orc_13/0/picture_teaser_items/0/text_files")
        end

        it "should be possible to call a node multiple times" do
          children = subject[:orc_13]
          expect(children).to_not be_nil
          expect(subject[:orc_13]).to eq(children)
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
          expect(node.parent.uuid).to eq(subject.uuid)
          expect(node.parent.parent.uuid).to eq('21cbc762-bdcd-4520-9eff-1928986fb419')
        end
      end

      describe "Type conversion" do
        describe "date conversion" do
          it "should properly convert a iso 8601 time string" do
            time = subject.send(:jcr_time_string_to_datetime, "2010-04-13T09:35:01.322+02:00")
            expect(time.year).to eq(2010)
            expect(time.month).to eq(4)
            expect(time.day).to eq(13)
            expect(time.hour).to eq(9)
            expect(time.minute).to eq(35)
            expect(time.second).to eq(1)
            expect(time.zone).to eq("+02:00")
          end

          it "should return the original string if it is not an iso8601 format" do
            time = subject.send(:jcr_time_string_to_datetime, "2010-04-13F09:35:01.322+02:00")
            expect(time).to eq("2010-04-13F09:35:01.322+02:00")
          end

          it "should handle null values" do
            time = subject.send(:jcr_time_string_to_datetime, nil)
            expect(time).to be nil
          end

          it "should convert Magnolia's Date notation: e.g. 2013-06-05T22:00:00.000Z" do
            time = subject.send(:jcr_time_string_to_datetime, "2013-06-05T22:00:00.000Z")
            expect(time.year).to eq(2013)
            expect(time.month).to eq(6)
            expect(time.day).to eq(6)
          end

          it "should convert Magnolia's Date notation to a date object" do
            time = subject.send(:jcr_time_string_to_datetime, "2013-06-05T22:00:00.000Z")
            expect(time).to be_a(Date)
          end
        end

        describe "boolean conversion" do
          it "should not touch strings" do
            value = subject.send(:mgnl_boolean_string_to_boolean, "Some string")
            expect(value).to eq("Some string")
          end

          it "should convert true values" do
            value = subject.send(:mgnl_boolean_string_to_boolean, "true")
            expect(value).to be true
          end

          it "should convert false values" do
            value = subject.send(:mgnl_boolean_string_to_boolean, "false")
            expect(value).to be false
          end
        end
      end

      describe "persistence" do
        it "should not be persisted as a new node" do
          node = Node.new
          expect(node).to_not be_persisted
        end

        it "should be persisted if constructed from an api response" do
          api_response = File.read(File.dirname(__FILE__) + "/../../fixtures/api/homepage.json")
          node = Node.new(json_response: api_response)
          expect(node).to be_persisted
        end
      end

      describe "initialize from hash" do
        it "should set a property" do
          node = Node.new(name: "A name")
          expect(node[:name]).to eq("A name")
        end

        it "should not be possible to set 'forbidden' JCR properties" do
          Node::PROHIBITED_JCR_PROPERTIES.each do |prop|
            expect { Node.new(prop => "value") }.to raise_error(RuntimeError, /cannot be set manually/)
          end
        end

        it "should not be possible to set 'forbidden' Manglia properties" do
          Node::PROHIBITED_MGNL_PROPERTIES.each do |prop|
            expect { Node.new(prop => "value") }.to raise_error(RuntimeError, /cannot be set manually/)
          end
        end

        it "should directly set allowed JCR properties" do
          Node::SETABLE_JCR_PROPERTIES.each do |prop|
            node = Node.new(prop => "value")
            expect(node.send(prop)).to eq("value")
          end
        end

        it "should should not set a hash-based value for a directly allowed JCR property" do
          Node::SETABLE_JCR_PROPERTIES.each do |prop|
            node = Node.new(prop => "value")
            expect(node[prop]).to be_nil
          end
        end

        it "should directly set allowed Magnolia properties" do
          Node::SETABLE_MGNL_PROPERTIES.each do |prop|
            node = Node.new(prop => "value")
            expect(node.send(prop)).to eq("value")
          end
        end

        it "should should not set a hash-based value for a directly allowed Magnolia property" do
          Node::SETABLE_MGNL_PROPERTIES.each do |prop|
            node = Node.new(prop => "value")
            expect(node[prop]).to be_nil
          end
        end
      end
    end
  end
end
