require 'spec_helper'

module Sinicum
  module Imaging
    describe ImagingFile do
      context "dam" do
        it "should normalize the path" do
          file = ImagingFile.new("/dam/pa.th/to.jpg")
          file.normalized_request_path.should eq("/damfiles/default/pa.th/to.jpg")
          file.extension.should eq("jpg")
          file.fingerprint.should be nil
        end

        it "should normalize not touch a regular imaging path" do
          file = ImagingFile.new("/damfiles/default/path/to")
          file.normalized_request_path.should eq("/damfiles/default/path/to")
          file.extension.should be nil
          file.fingerprint.should be nil
        end

        it "should ignore a possible document repetition if the last two path parts do not match" do
          file = ImagingFile.new("/dam/pa.th/to/tu.jpg")
          file.normalized_request_path.should eq("/damfiles/default/pa.th/to/tu.jpg")
          file.extension.should eq("jpg")
          file.fingerprint.should be nil
        end

        it "should extract the cache key with a suffix" do
          file = ImagingFile.new(
            "/damfiles/default/path/to/file-de89466a9267dccc7712379f44e6cd85.jpg")
          file.normalized_request_path.should eq("/damfiles/default/path/to/file")
          file.extension.should eq("jpg")
          file.fingerprint.should eq("de89466a9267dccc7712379f44e6cd85")
        end

        it "should extract the cache key without a suffix" do
          file = ImagingFile.new(
            "/damfiles/default/path/to/file-de89466a9267dccc7712379f44e6cd85")
          file.normalized_request_path.should eq("/damfiles/default/path/to/file")
          file.extension.should be nil
          file.fingerprint.should eq("de89466a9267dccc7712379f44e6cd85")
        end

        describe "#cache_time" do
          it "should have a cache time of one day for regular requests" do
            file = ImagingFile.new("/damfiles/default/path/to")
            file.cache_time.should eq(24 * 60 * 60)
          end

          it "should have a cache time of a week day for requests with a fingerprint" do
            file = ImagingFile.new("/damfiles/default/path/to-de89466a9267dccc7712379f44e6cd85")
            file.cache_time.should eq(7 * 24 * 60 * 60)
          end
        end
      end

      context "dms" do
        it "should normalize the path" do
          file = ImagingFile.new("/dms/pa.th/to.jpg")
          file.normalized_request_path.should eq("/dmsfiles/default/pa.th/to")
          file.extension.should eq("jpg")
          file.fingerprint.should be nil
        end

        it "should normalize not touch a regular imaging path" do
          file = ImagingFile.new("/dmsfiles/default/path/to")
          file.normalized_request_path.should eq("/dmsfiles/default/path/to")
          file.extension.should be nil
          file.fingerprint.should be nil
        end

        it "should extract the cache key with a suffix" do
          file = ImagingFile.new(
            "/dmsfiles/default/path/to/file-de89466a9267dccc7712379f44e6cd85.jpg")
          file.normalized_request_path.should eq("/dmsfiles/default/path/to/file")
          file.extension.should eq("jpg")
          file.fingerprint.should eq("de89466a9267dccc7712379f44e6cd85")
        end

        it "should ignore a possible document repetition if the last two path parts do not match" do
          file = ImagingFile.new("/dms/pa.th/to/tu.jpg")
          file.normalized_request_path.should eq("/dmsfiles/default/pa.th/to/tu")
          file.extension.should eq("jpg")
          file.fingerprint.should be nil
        end

        it "should extract the cache key with a suffix" do
          file = ImagingFile.new("/dmsfiles/default/path/to/" \
            "file-de89466a9267dccc7712379f44e6cd85.jpg")
          file.normalized_request_path.should eq("/dmsfiles/default/path/to/file")
          file.extension.should eq("jpg")
          file.fingerprint.should eq("de89466a9267dccc7712379f44e6cd85")
        end

        it "should extract the cache key without a suffix" do
          file = ImagingFile.new(
            "/dmsfiles/default/path/to/file-de89466a9267dccc7712379f44e6cd85")
          file.normalized_request_path.should eq("/dmsfiles/default/path/to/file")
          file.extension.should be nil
          file.fingerprint.should eq("de89466a9267dccc7712379f44e6cd85")
        end

        describe "#cache_time" do
          it "should have a cache time of one day for regular requests" do
            file = ImagingFile.new("/dmsfiles/default/path/to")
            file.cache_time.should eq(24 * 60 * 60)
          end

          it "should have a cache time of a week day for requests with a fingerprint" do
            file = ImagingFile.new("/dmsfiles/default/path/to-de89466a9267dccc7712379f44e6cd85")
            file.cache_time.should eq(7 * 24 * 60 * 60)
          end
        end
      end
    end
  end
end
