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
        config.host.should eq("some.host")
        config.port.should eq("8080")
        config.protocol.should eq("https")
        config.path_prefix.should eq("/some_prefix")
        config.username.should eq("user")
        config.password.should eq("pass")
      end

      it "should add a / to the path prefix if not automatically given" do
        subject.path_prefix = "some_prefix"
        subject.path_prefix.should eq("/some_prefix")
      end

      it "should not add a / to the path prefix if it does not exist in the configuration" do
        subject.path_prefix = "/some_prefix"
        subject.path_prefix.should eq("/some_prefix")
      end

      it "should construct a right base url only with the mininum parameters" do
        config = JcrConfiguration.new
        config.base_url.should eq("http://localhost/sinicum-rest")
      end

      it "should construct a right base_proto_host_port only with the mininum parameters" do
        config = JcrConfiguration.new
        config.base_proto_host_port.should eq("http://localhost")
      end

      it "should respect the various configuration parameters" do
        config = JcrConfiguration.new(
          host: "some.host", port: "8443", protocol: "https",
          path_prefix: "some_prefix", username: "user", password: "pass"
        )
        config.base_url.should eq("https://some.host:8443/some_prefix")
      end

      it "should respect the varios configuration parameters for the host part" do
        config = JcrConfiguration.new(
          host: "some.host", port: "8443", protocol: "https",
          path_prefix: "some_prefix", username: "user", password: "pass"
        )
        config.base_proto_host_port.should eq("https://some.host:8443")
      end
    end
  end
end
