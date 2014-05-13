# encoding: utf-8
module Sinicum
  module Imaging
    # Representation of a DAM file as seen by the imaging middleware.
    class ImagingFile
      ORIGINAL_DAM_PATH_START = ::Sinicum::Imaging.dam_path_prefix + "/"
      ORIGINAL_DAM_PATH_REPLACEMENT = ::Sinicum::Imaging.path_prefix + "/" +
        ::Sinicum::Imaging.default_converter_name + "/"
      ORIGINAL_DMS_PATH_START = ::Sinicum::Imaging.dms_path_prefix + "/"
      ORIGINAL_DMS_PATH_REPLACEMENT = ::Sinicum::Imaging.path_prefix_mgnl4 + "/" +
        ::Sinicum::Imaging.default_converter_name + "/"
      DEFAULT_CACHE_TIME = 24 * 60 * 60
      FINGERPRINT_CACHE_TIME = 7 * 24 * 60 * 60

      attr_reader :normalized_request_path, :extension, :fingerprint, :workspace

      # Public: Create a new instance
      #
      # path_info - The request's path_info
      def initialize(path_info)
        @path_info = path_info
        set_up
      end

      def result?
        !!imaging_result
      end

      def path
        imaging_result.path
      end

      def filename
        imaging_result.filename
      end

      def cache_time
        if fingerprint
          FINGERPRINT_CACHE_TIME
        else
          DEFAULT_CACHE_TIME
        end
      end

      private

      def imaging_result
        @imaging_result ||= create_imaging_result
      end

      def create_imaging_result
        result = ::Sinicum::Imaging::Imaging.rendered_resource(
          @file_asset_path, extension, @renderer, fingerprint, @workspace)
        result
      end

      # Private: "Normalizes" the request path. In particular, a request
      # to "/dam/something" gets converted to
      # "/damfiles/default/something".
      #
      # Then it extracts the fingerprint and extension, if any of them
      # exist.
      def set_up
        if @path_info.index(ORIGINAL_DAM_PATH_START) == 0
          path = @path_info.sub(ORIGINAL_DAM_PATH_START, ORIGINAL_DAM_PATH_REPLACEMENT)
          path = cutoff_document_path_repetition(path)
        elsif @path_info.index(ORIGINAL_DMS_PATH_START) == 0
          path = @path_info.sub(ORIGINAL_DMS_PATH_START, ORIGINAL_DMS_PATH_REPLACEMENT)
          path = cutoff_document_path_repetition(path)
        else
          path = @path_info.dup
        end
        @normalized_request_path, @extension, @fingerprint = extract_fingerprint(path)
        if path =~ /^\/dam/
          @workspace = :dam
        elsif path =~ /^\/dms/
          @workspace = :dms
        end
        renderer_image = normalized_request_path[
          ::Sinicum::Imaging.path_prefix.size + 1, normalized_request_path.size]
        @renderer = renderer_image[0, renderer_image.index("/")]
        @file_asset_path = renderer_image[@renderer.size, renderer_image.size]
        nil
      end

      def extract_fingerprint(path)
        if match = path.match(/(.+?)-(\h{32})(\.\w+)?$/)
          extension = nil
          extension = match[3][1..match[3].length] if match[3]
          [match[1], extension, match[2]]
        else
          extension = nil
          if match = path.match(/(.+)\.(\w+)$/)
            extension = match[2]
            path = match[1]
          end
          [path, extension, nil]
        end
      end

      def cutoff_document_path_repetition(path)
        parts = path.split("/")
        if parts.size > 3
          if match = parts.last.match(/(.+)(\.\w+)$/)
            last_part = match[1]
            if last_part == parts[parts.size - 2]
              path = path[0..(path.rindex("/") - 1)] + match[2]
            end
          end
        end
        path
      end
    end
  end
end
