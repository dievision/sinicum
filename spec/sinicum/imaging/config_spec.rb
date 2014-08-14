require "spec_helper"

module Sinicum
  module Imaging
    describe Config do
      test_config = File.join(File.dirname(__FILE__), "imaging.yml")
      test_config_default = File.join(File.dirname(__FILE__), "imaging_default.yml")

      before(:each) do
        @tmpdir = File.join("/", "tmp", "imaging")
        FileUtils.mkdir(@tmpdir) unless File.exist?(@tmpdir)
      end

      after(:each) do
        FileUtils.rm_r(@tmpdir) if File.exist?(@tmpdir)
      end

      it "should not initialize if not yet configured" do
        expect { Config.instance }.to raise_error(RuntimeError, /config/)
      end

      it "should use the correct configuration file" do
        config = Config.configure(test_config)
        config.send(:config_file).should == test_config
      end

      it "should set the right root directory" do
        config = Config.configure(test_config)
        config.root_dir.should == @tmpdir.to_s
      end

      it "should store all files under the root dir" do
        config = Config.configure(test_config)
        config.file_dir.should =~ /#{config.root_dir}\/.+/
        config.tmp_dir.should =~ /#{config.root_dir}\/.+/
        config.version_file.should =~ /#{config.root_dir}\/.+/
      end

      it "should return the default converter if no valid renderer is given" do
        config = Config.configure(test_config)
        config.converter(:inexistent).should be_a DefaultConverter
      end

      it "should return the right converter" do
        config = Config.configure(test_config)
        config.converter(:slideshow_thumbs).should be_a ResizeCropConverter
        config.converter(:margin_column).should be_a MaxSizeConverter
      end

      it "should raise an error if a configuration file has a renderer named 'default'" do
        expect do
           Config.configure(test_config_default)
        end.to raise_error
      end
    end
  end
end
