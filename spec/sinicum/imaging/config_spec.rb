require "spec_helper"

module Sinicum
  module Imaging
    describe Config do
      test_config = File.join(File.dirname(__FILE__), "../../fixtures/imaging.yml")
      test_config_default = File.join(File.dirname(__FILE__), "../../fixtures/imaging_default.yml")
      test_config_faulty = File.join(File.dirname(__FILE__), "../../fixtures/imaging_without_apps.yml")

      before(:each) do
        @tmpdir = File.join("/", "tmp", "imaging")
        FileUtils.mkdir(@tmpdir) unless File.exist?(@tmpdir)
      end

      after(:each) do
        FileUtils.rm_r(@tmpdir) if File.exist?(@tmpdir)
      end

      it "should use the correct configuration file" do
        config = Config.configure(test_config)
        expect(config.send(:config_file)).to eq(test_config)
      end

      it "should set the right root directory" do
        config = Config.configure(test_config)
        expect(config.root_dir).to eq(@tmpdir.to_s)
      end

      it "should store all files under the root dir" do
        config = Config.configure(test_config)
        expect(config.file_dir).to match(/#{config.root_dir}\/.+/)
        expect(config.tmp_dir).to match(/#{config.root_dir}\/.+/)
        expect(config.version_file).to match(/#{config.root_dir}\/.+/)
      end

      it "should return the default converter if no valid renderer is given" do
        config = Config.configure(test_config)
        expect(config.converter(:inexistent)).to be_a DefaultConverter
      end

      it "should return the right converter" do
        config = Config.configure(test_config)
        expect(config.converter(:slideshow_thumbs)).to be_a ResizeCropConverter
        expect(config.converter(:margin_column)).to be_a MaxSizeConverter
      end

      it "should raise an error if a configuration file has a renderer named 'default'" do
        expect do
           Config.configure(test_config_default)
        end.to raise_error(RuntimeError, /No renderer with/)
      end

      it "should raise an error if no apps are configured" do
        expect do
           Config.configure(test_config_faulty)
        end.to raise_error(RuntimeError, /No apps are configured/)
      end
    end
  end
end
