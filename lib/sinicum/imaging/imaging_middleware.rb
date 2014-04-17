module Sinicum
  module Imaging
    # Public: Rack middleware to handle a request to the imaging fuctionality.
    class ImagingMiddleware < Rack::File
      SUFFIX_REGEX = /\.\w+$/
      DEFAULT_CACHE_TIME = 24 * 60 * 60

      def initialize(app)
        @app = app
      end

      def call(env)
        if on_imaging_path?(env['PATH_INFO'])
          dup._call(env)
        else
          @app.call(env)
        end
      end

      def _call(env)
        unless ALLOWED_VERBS.include? env["REQUEST_METHOD"]
          return fail(405, "Method Not Allowed")
        end
        request = Rack::Request.new(env)
        imaging_file = ImagingFile.new(request.path_info)
        if imaging_file.result?
          @path = imaging_file.path
          available = begin
                        F.file?(@path) && F.readable?(@path)
                      rescue SystemCallError
                        false
                      end
        end
        if available
          @headers = {}
          @headers["Content-Disposition"] = "inline; filename=\"#{imaging_file.filename}\""
          if Rails.configuration.action_controller.perform_caching
            @headers["Cache-Control"] = "max-age=#{imaging_file.cache_time}, public"
          end
          serving(env)
        else
          fail(404, "File not found: #{request.path_info}")
        end
      end

      private

      def on_imaging_path?(path)
        path && (path.index(::Sinicum::Imaging.path_prefix) == 0 ||
          path.index(ImagingFile::ORIGINAL_DAM_PATH_START) == 0 ||
          path.index(::Sinicum::Imaging.path_prefix_mgnl4) == 0 ||
          path.index(ImagingFile::ORIGINAL_DMS_PATH_START) == 0)
      end
    end
  end
end
