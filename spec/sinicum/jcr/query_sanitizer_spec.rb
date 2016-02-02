require 'spec_helper'

module Sinicum
  module Jcr
    describe QuerySanitizer do
      let(:mock_class) { Class.new { include QuerySanitizer } }
      subject { mock_class.new }

      it "should not touch a query if no parameters are given" do
        expect(subject.send(:sanitize_query, "xpath", "query")).to eq("query")
      end

      it "should not touch a query if empty parameters are given" do
        expect(subject.send(:sanitize_query, "xpath", "query", {})).to eq("query")
      end

      it "should sanitize a sql query" do
        query = "select * from microphone where lower(url_path) = ':name' " \
          "and jcr:path like '/products/microphones/en/%'"
        result = subject.send(:sanitize_query, "xpath", query, name: "A name")
        expect(result).to eq("select * from microphone where lower(url_path) = 'A name' " \
          "and jcr:path like '/products/microphones/en/%'")
      end
    end
  end
end
