require "spec_helper"

describe "Utils" do

  describe "uuid_check" do

    it "should identify a uuid" do
      Sinicum::Util.is_a_uuid?("facc47c0-a3d8-4cf0-9db5-930d287e01cb")
      .should == true
    end

    it "should identify a uuid and be case-insensitive" do
      Sinicum::Util.is_a_uuid?("FACC47C0-A3D8-4CF0-9DB5-930D287E01CB")
      .should == true
    end

    it "should identify something thats not a uuid" do
      Sinicum::Util.is_a_uuid?("no uuid")
      .should == false
    end

    it "should recognize no-hex characters" do
      Sinicum::Util.is_a_uuid?("gacc47c0-a3d8-4cf0-9db5-930d287e01cb")
      . should == false
    end

    it "should should only allow objects that respond to 'match'" do
      Sinicum::Util.is_a_uuid?("facc47c0-a3d8-4cf0-9db5-930d287e01cb".to_sym)
      .should be true
    end

  end

end
