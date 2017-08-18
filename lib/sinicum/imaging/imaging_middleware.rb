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
          if imaging_file.fingerprinted?
            @path = imaging_file.path
            available = begin
                          F.file?(@path) && F.readable?(@path)
                        rescue SystemCallError
                          false
                        end
          elsif imaging_file.calculated_asset_path
            return redirect(imaging_file.calculated_asset_path)
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

      def redirect(location)
        [302, { 'Location' => location, 'Content-Type' => 'text/html' }, ['Found (Moved Temporarily)']]
      end
    end
  end
end
