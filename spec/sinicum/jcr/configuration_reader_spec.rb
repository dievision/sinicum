require 'spec_helper'

module Sinicum
  module Jcr
    describe ConfigurationReader do
      it "should return null if no configuration file is found" do
        config = ConfigurationReader.read_from_file("nonexistent")

        expect(config).to be nil
      end

      it "should return the correct value for a regular YAML file" do
        config = ConfigurationReader.read_from_file(config_file_name("sinicum_server.yml"))

        expect(config["host"]).to eq("localhost")
        expect(config["port"]).to eq(8081)
        expect(config["username"]).to eq("superuser")
        expect(config["password"]).to eq("password")
      end

      it "should respect Rails environments" do
        allow(Rails).to receive(:env).and_return("production")
        config = ConfigurationReader.read_from_file(config_file_name("sinicum_server.yml"))

        expect(config["host"]).to eq("production.host")
      end

      it "should respect Rails environments" do
        allow(Rails).to receive(:env).and_return("production")
        config = ConfigurationReader.read_from_file(config_file_name("sinicum_server.yml"))

        expect(config["host"]).to eq("production.host")
      end

      it "should read YAML files with ERB syntax" do
        config = ConfigurationReader.read_from_file(config_file_name("sinicum_server_erb.yml"))

        expect(config["port"]).to eq(8088)
      end

      def config_file_name(filename)
        file_path = File.join("../../../fixtures/config", filename)
        File.expand_path(file_path, __FILE__)
      end
    end
  end
end
