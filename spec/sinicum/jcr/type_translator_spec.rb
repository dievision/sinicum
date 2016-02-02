require 'spec_helper'

module Sinicum
  module Jcr
    describe TypeTranslator do
      let(:first_translator) { Class.new }
      let(:second_translator) { Class.new }
      let(:third_translator) { Class.new }
      let(:fourth_translator) { Class.new }

      before(:each) { TypeTranslator.clear }
      after(:each) { TypeTranslator.reset }

      it "should add a new translator to the translator stack" do
        TypeTranslator.use(first_translator)
        TypeTranslator.use(second_translator)
        expect(TypeTranslator.list).to eq([second_translator, first_translator])
      end

      it "should reset the stack" do
        TypeTranslator.clear
        TypeTranslator.reset
        expect(TypeTranslator.list).to eq(TypeTranslator::DEFAULT_TRANSLATORS)
      end

      describe "swapping" do
        let(:new_translator) { Class.new }

        before(:each) do
          [first_translator, second_translator, third_translator, fourth_translator].each do |t|
            TypeTranslator.use(t)
          end
        end

        it "should clear the stack" do
          TypeTranslator.clear
          expect(TypeTranslator.list).to eq([])
        end
      end
    end
  end
end
