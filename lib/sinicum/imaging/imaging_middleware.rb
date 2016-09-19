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
        if ::Sinicum::Imaging.on_imaging_path?(env['PATH_INFO'])
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
                        ::File.file?(@path) && ::File.readable?(@path)
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
    end
  end
end
