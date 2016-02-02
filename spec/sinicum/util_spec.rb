require "spec_helper"

describe "Utils" do

  describe "uuid_check" do

    it "should identify a uuid" do
      expect(Sinicum::Util.is_a_uuid?("facc47c0-a3d8-4cf0-9db5-930d287e01cb"))
        .to be_truthy
    end

    it "should identify a uuid and be case-insensitive" do
      expect(Sinicum::Util.is_a_uuid?("FACC47C0-A3D8-4CF0-9DB5-930D287E01CB"))
        .to be_truthy
    end

    it "should identify something thats not a uuid" do
      expect(Sinicum::Util.is_a_uuid?("no uuid"))
        .to be_falsey
    end

    it "should recognize no-hex characters" do
      expect(Sinicum::Util.is_a_uuid?("gacc47c0-a3d8-4cf0-9db5-930d287e01cb"))
        .to be_falsey
    end

    it "should should only allow objects that respond to 'match'" do
      expect(Sinicum::Util.is_a_uuid?("facc47c0-a3d8-4cf0-9db5-930d287e01cb".to_sym))
        .to be_truthy
    end

  end

end
