# encoding: utf-8
module Sinicum
  module Imaging
    # Representation of a DAM file as seen by the imaging middleware.
    class ImagingFile
      DEFAULT_CACHE_TIME = 24 * 60 * 60
      FINGERPRINT_CACHE_TIME = 7 * 24 * 60 * 60

      attr_reader :normalized_request_path, :extension, :fingerprint, :app,
        :workspace

      # Public: Create a new instance
      #
      # path_info - The request's path_info
      def initialize(path_info)
        @path_info = path_info
        @app = ::Sinicum::Imaging.app_from_path(path_info)
        set_up
      end

      def result?
        !!imaging_result
      end

      def fingerprinted?
        !!fingerprint
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

      def calculated_asset_path
        @calculated_asset_path ||= begin
          doc = Sinicum::Jcr::Node.find_by_path(@workspace, @file_asset_path)
          if doc && doc.is_a?(Sinicum::Jcr::Dam::Document)
            doc.path(converter: @renderer)
          end
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
        if @path_info.index(@app['magnolia_prefix'] + '/') == 0
          path = @path_info.sub(@app['magnolia_prefix'] + '/',
            @app['imaging_prefix'] + '/' + ::Sinicum::Imaging.default_converter_name + "/")
          path = cutoff_document_path_repetition(path)
        else
          path = @path_info.dup
        end
        @normalized_request_path, @extension, @fingerprint = extract_fingerprint(path)
        renderer_image = normalized_request_path[
          @app['imaging_prefix'].size + 1, normalized_request_path.size]
        @renderer = renderer_image[0, renderer_image.index("/")]
        @workspace = @app['workspace']
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
