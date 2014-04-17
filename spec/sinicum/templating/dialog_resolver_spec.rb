require 'spec_helper'

module Sinicum
  module Templating
    describe DialogResolver do
      it "should correctly split a template path" do
        result = subject.send(:split_template_path, "templating:pages/helloWorld")
        expected_result = { module: "templating", type: :page, name: "helloWorld" }
        expect(result).to eq(expected_result)
      end
    end
  end
end
