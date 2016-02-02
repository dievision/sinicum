module Sinicum; end
require_relative '../../../lib/sinicum/jcr/jcr_configuration'

module Sinicum
  module Jcr
    describe JcrConfiguration do
      it "should respect the configuration parameters" do
        config = JcrConfiguration.new(
          host: "some.host", port: "8080", protocol: "https",
          path_prefix: "/some_prefix", username: "user", password: "pass"
        )
        expect(config.host).to eq("some.host")
        expect(config.port).to eq("8080")
        expect(config.protocol).to eq("https")
        expect(config.path_prefix).to eq("/some_prefix")
        expect(config.username).to eq("user")
        expect(config.password).to eq("pass")
      end

      it "should add a / to the path prefix if not automatically given" do
        subject.path_prefix = "some_prefix"
        expect(subject.path_prefix).to eq("/some_prefix")
      end

      it "should not add a / to the path prefix if it does not exist in the configuration" do
        subject.path_prefix = "/some_prefix"
        expect(subject.path_prefix).to eq("/some_prefix")
      end

      it "should construct a right base url only with the mininum parameters" do
        config = JcrConfiguration.new
        expect(config.base_url).to eq("http://localhost/sinicum-rest")
      end

      it "should construct a right base_proto_host_port only with the mininum parameters" do
        config = JcrConfiguration.new
        expect(config.base_proto_host_port).to eq("http://localhost")
      end

      it "should respect the various configuration parameters" do
        config = JcrConfiguration.new(
          host: "some.host", port: "8443", protocol: "https",
          path_prefix: "some_prefix", username: "user", password: "pass"
        )
        expect(config.base_url).to eq("https://some.host:8443/some_prefix")
      end

      it "should respect the varios configuration parameters for the host part" do
        config = JcrConfiguration.new(
          host: "some.host", port: "8443", protocol: "https",
          path_prefix: "some_prefix", username: "user", password: "pass"
        )
        expect(config.base_proto_host_port).to eq("https://some.host:8443")
      end
    end
  end
end
