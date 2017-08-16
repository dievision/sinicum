require 'spec_helper'

module Sinicum
  module Imaging
    describe ImagingFile do
      context "dam" do
        it "should normalize the path" do
          file = ImagingFile.new("/dam/pa.th/to.jpg")
          expect(file.normalized_request_path).to eq("/damfiles/default/pa.th/to")
          expect(file.extension).to eq("jpg")
          expect(file.fingerprint).to be nil
        end

        it "should normalize not touch a regular imaging path" do
          file = ImagingFile.new("/damfiles/default/path/to")
          expect(file.normalized_request_path).to eq("/damfiles/default/path/to")
          expect(file.extension).to be nil
          expect(file.fingerprint).to be nil
        end

        it "should ignore a possible document repetition if the last two path parts do not match" do
          file = ImagingFile.new("/dam/pa.th/to/tu.jpg")
          expect(file.normalized_request_path).to eq("/damfiles/default/pa.th/to/tu")
          expect(file.extension).to eq("jpg")
          expect(file.fingerprint).to be nil
        end

        it "should extract the cache key with a suffix" do
          file = ImagingFile.new(
            "/damfiles/default/path/to/file-de89466a9267dccc7712379f44e6cd85.jpg")
          expect(file.normalized_request_path).to eq("/damfiles/default/path/to/file")
          expect(file.extension).to eq("jpg")
          expect(file.fingerprint).to eq("de89466a9267dccc7712379f44e6cd85")
        end

        it "should extract the cache key without a suffix" do
          file = ImagingFile.new(
            "/damfiles/default/path/to/file-de89466a9267dccc7712379f44e6cd85")
          expect(file.normalized_request_path).to eq("/damfiles/default/path/to/file")
          expect(file.extension).to be nil
          expect(file.fingerprint).to eq("de89466a9267dccc7712379f44e6cd85")
        end

        describe "#cache_time" do
          it "should have a cache time of one day for regular requests" do
            file = ImagingFile.new("/damfiles/default/path/to")
            expect(file.cache_time).to eq(24 * 60 * 60)
          end

          it "should have a cache time of a week day for requests with a fingerprint" do
            file = ImagingFile.new("/damfiles/default/path/to-de89466a9267dccc7712379f44e6cd85")
            expect(file.cache_time).to eq(7 * 24 * 60 * 60)
          end
        end
      end

      context "dms" do
        it "should normalize the path" do
          file = ImagingFile.new("/dms/pa.th/to.jpg")
          expect(file.normalized_request_path).to eq("/dmsfiles/default/pa.th/to")
          expect(file.extension).to eq("jpg")
          expect(file.fingerprint).to be nil
        end

        it "should normalize not touch a regular imaging path" do
          file = ImagingFile.new("/dmsfiles/default/path/to")
          expect(file.normalized_request_path).to eq("/dmsfiles/default/path/to")
          expect(file.extension).to be nil
          expect(file.fingerprint).to be nil
        end

        it "should extract the cache key with a suffix" do
          file = ImagingFile.new(
            "/dmsfiles/default/path/to/file-de89466a9267dccc7712379f44e6cd85.jpg")
          expect(file.normalized_request_path).to eq("/dmsfiles/default/path/to/file")
          expect(file.extension).to eq("jpg")
          expect(file.fingerprint).to eq("de89466a9267dccc7712379f44e6cd85")
        end

        it "should ignore a possible document repetition if the last two path parts do not match" do
          file = ImagingFile.new("/dms/pa.th/to/tu.jpg")
          expect(file.normalized_request_path).to eq("/dmsfiles/default/pa.th/to/tu")
          expect(file.extension).to eq("jpg")
          expect(file.fingerprint).to be nil
        end

        it "should extract the cache key with a suffix" do
          file = ImagingFile.new("/dmsfiles/default/path/to/" \
            "file-de89466a9267dccc7712379f44e6cd85.jpg")
          expect(file.normalized_request_path).to eq("/dmsfiles/default/path/to/file")
          expect(file.extension).to eq("jpg")
          expect(file.fingerprint).to eq("de89466a9267dccc7712379f44e6cd85")
        end

        it "should extract the cache key without a suffix" do
          file = ImagingFile.new(
            "/dmsfiles/default/path/to/file-de89466a9267dccc7712379f44e6cd85")
          expect(file.normalized_request_path).to eq("/dmsfiles/default/path/to/file")
          expect(file.extension).to be nil
          expect(file.fingerprint).to eq("de89466a9267dccc7712379f44e6cd85")
        end

        describe "#cache_time" do
          it "should have a cache time of one day for regular requests" do
            file = ImagingFile.new("/dmsfiles/default/path/to")
            expect(file.cache_time).to eq(24 * 60 * 60)
          end

          it "should have a cache time of a week day for requests with a fingerprint" do
            file = ImagingFile.new("/dmsfiles/default/path/to-de89466a9267dccc7712379f44e6cd85")
            expect(file.cache_time).to eq(7 * 24 * 60 * 60)
          end
        end
      end

      context "videos content app" do
        it "should normalize the path" do
          file = ImagingFile.new("/videos/pa.th/to.jpg")
          expect(file.normalized_request_path).to eq("/videofiles/default/pa.th/to")
          expect(file.extension).to eq("jpg")
          expect(file.fingerprint).to be nil
        end

        it "should normalize not touch a regular imaging path" do
          file = ImagingFile.new("/videofiles/default/path/to")
          expect(file.normalized_request_path).to eq("/videofiles/default/path/to")
          expect(file.extension).to be nil
          expect(file.fingerprint).to be nil
        end

        it "should ignore a possible document repetition if the last two path parts do not match" do
          file = ImagingFile.new("/videos/pa.th/to/tu.jpg")
          expect(file.normalized_request_path).to eq("/videofiles/default/pa.th/to/tu")
          expect(file.extension).to eq("jpg")
          expect(file.fingerprint).to be nil
        end

        it "should extract the cache key with a suffix" do
          file = ImagingFile.new(
            "/videofiles/default/path/to/file-de89466a9267dccc7712379f44e6cd85.jpg")
          expect(file.normalized_request_path).to eq("/videofiles/default/path/to/file")
          expect(file.extension).to eq("jpg")
          expect(file.fingerprint).to eq("de89466a9267dccc7712379f44e6cd85")
        end

        it "should extract the cache key without a suffix" do
          file = ImagingFile.new(
            "/videofiles/default/path/to/file-de89466a9267dccc7712379f44e6cd85")
            expect(file.normalized_request_path).to eq("/videofiles/default/path/to/file")
            expect(file.extension).to be nil
            expect(file.fingerprint).to eq("de89466a9267dccc7712379f44e6cd85")
        end

        describe "#cache_time" do
          it "should have a cache time of one day for regular requests" do
            file = ImagingFile.new("/videofiles/default/path/to")
            expect(file.cache_time).to eq(24 * 60 * 60)
          end

          it "should have a cache time of a week day for requests with a fingerprint" do
            file = ImagingFile.new("/videofiles/default/path/to-de89466a9267dccc7712379f44e6cd85")
            expect(file.cache_time).to eq(7 * 24 * 60 * 60)
          end
        end
      end

      context "srcset options" do
        it "should extract the cache key with a suffix" do
          file = ImagingFile.new("/damfiles/etc/pp/Header-Inhalt-TUI-Presse.jpg2_050-d9a4dc816a85ac55bad73ee5f23c8f9e.jpg")
          expect(file.normalized_request_path).to eq("/damfiles/etc/pp/Header-Inhalt-TUI-Presse.jpg2")
          expect(file.extension).to eq("jpg")
          expect(file.fingerprint).to eq("d9a4dc816a85ac55bad73ee5f23c8f9e")
          expect(file.srcset_option).to eq("050")
        end

        it "should extract the cache key without a suffix" do
          file = ImagingFile.new("/damfiles/etc/pp/Header-Inhalt-TUI-Presse.jpg2_200-d9a4dc816a85ac55bad73ee5f23c8f9e")
          expect(file.normalized_request_path).to eq("/damfiles/etc/pp/Header-Inhalt-TUI-Presse.jpg2")
          expect(file.extension).to eq(nil)
          expect(file.fingerprint).to eq("d9a4dc816a85ac55bad73ee5f23c8f9e")
          expect(file.srcset_option).to eq("200")
        end

        it "should extract the cache key with a suffix but no srcset_option" do
          file = ImagingFile.new("/damfiles/etc/pp/Header-Inhalt-TUI-Presse.jpg2-d9a4dc816a85ac55bad73ee5f23c8f9e.jpg")
          expect(file.normalized_request_path).to eq("/damfiles/etc/pp/Header-Inhalt-TUI-Presse.jpg2")
          expect(file.extension).to eq("jpg")
          expect(file.fingerprint).to eq("d9a4dc816a85ac55bad73ee5f23c8f9e")
          expect(file.srcset_option).to eq(nil)
        end
      end
    end
  end
end
