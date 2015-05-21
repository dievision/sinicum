require 'tempfile'
require 'fileutils'

module Sinicum
  module Imaging
    # Internal: Class that handles more or less all of the imaging
    # functionality.
    class Imaging
      RENDER_MUTEX = Mutex.new
      DEFAULT_CONVERTER_NAME = "default"
      include Sinicum::Logger

      attr_reader :fingerprint

      # Render the image from path `original_path` with the renderer `renderer`
      #
      # @param [String] original_path The original path of the image.
      # @param [String] renderer The name of the renderer
      # @return [RenderResult] The result of the conversion
      def self.rendered_resource(original_path, extension, renderer, fingerprint, workspace = nil)
        imaging = Imaging.new(original_path, extension, renderer, fingerprint, workspace)
        result = imaging.fetch_image
        result
      end

      def initialize(original_path, extension, renderer, fingerprint, workspace = nil)
        @original_path = original_path
        @extension = extension
        @renderer = renderer
        @fingerprint = fingerprint
        @workspace = workspace
      end

      def fetch_image
        result = nil
        @image, @doc = find_image_objects_by_path(@original_path)
        if @image && @doc
          if convert_file?
            result = perform_conversion
          else
            format = converter.format
            mime_type =
              case format
              when "gif" then "image/gif"
              when "png" then "image/png"
              when "ogv" then "video/ogg"
              when "mp4" then "video/mp4"
              when "m4a" then "audio/mp4"
              when "ogg" then "audio/ogg"
              when "webm" then "audio/webm"
              else "image/jpeg"
              end
            result = RenderResult.new(
              file_rendered, mime_type,
              "#{@doc[:fileName]}.#{@doc[:extension]}", fingerprint)
          end
        end
        result
      end

      # The temporary file as it comes out of the repository
      def file_out
        @_file_out ||= File.join(config_data.tmp_dir, @renderer + "-" + "out" + "-" + random)
      end

      # The temporary file the converter writes to
      def file_converted
        @_file_converted ||= File.join(config_data.tmp_dir, @renderer + "-" + "converted" +
          "-" + random + "." + converter.format)
      end

      # The "final" file to be sent to the client
      def file_rendered
        @_file_rendered ||= File.join(config_data.file_dir, "/" + @renderer + "-" +
          converter.config_hash + "-" + @image.fingerprint +
          converter.format)
      end

      # Finds the image objects by path
      #
      # @param [String] original_path The original path
      # @return [Array] An `Array` in the form `[Image, Document]`
      def find_image_objects_by_path(original_path)
        result = [nil, nil]
        if @workspace == :dam
          image_node_path = original_path.gsub(/^\/dam/, "")
          image = Sinicum::Jcr::Node.find_by_path("dam", image_node_path)
        elsif @workspace == :dms
          image_node_path = original_path.gsub(/^\/dms/, "")
          image = Sinicum::Jcr::Node.find_by_path("dms", image_node_path)
        end
        if image
          doc = image.properties
          result = [image, doc]
        end
        result
      end

      private

      def perform_conversion
        RENDER_MUTEX.synchronize {
          out_file = File.open(file_out, "wb")
          out_file.close
          in_file = File.open(file_converted, "wb")
          begin
            write_doc_to_tempfile(in_file)
            in_file.close
            convert(in_file.path, out_file.path)
            FileUtils.mv(out_file.path, file_rendered)
            FileUtils.chmod(0644, file_rendered)
            RenderResult.new(
              file_rendered, @doc["jcr:mimeType"],
              "#{@doc[:fileName]}.#{@doc[:extension]}", fingerprint)
          rescue => e
            FileUtils.rm(out_file.path) if File.exist?(out_file.path)
            raise e
          ensure
            FileUtils.rm(in_file.path) if File.exist?(in_file.path)
          end
        }
      end

      def convert(infile_path, outfile_path)
        converter.convert(infile_path, outfile_path, @doc[:extension])
      end

      def write_doc_to_tempfile(tempfile)
        begin
          Sinicum::Jcr::Node.stream_attribute(@doc.jcr_workspace, @doc.path, "jcr:data", tempfile)
        rescue => e
          logger.error("Cannot write to tempfile: " + e.to_s)
        end
      end

      def convert_file?
        last_modified = @doc["jcr:lastModified"]
        # File.size == 0 is related to a (temporary?) bug on one server
        # should be possible to remove
        result = !File.exist?(file_rendered) || File.mtime(file_rendered) <
          last_modified || File.size(file_rendered) == 0
        result
      end

      def random
        @random ||= "#{Process.pid}-#{rand(1_000_000_000)}"
      end

      def config_data
        Config.read_configuration
      end

      def converter
        conv = config_data.converter(@renderer)
        conv.document = @image if conv
        conv
      end
    end

    # Internal: Simple wrapper around imaging results.
    class RenderResult
      attr_accessor :path, :mime_type, :filename, :fingerprint

      def initialize(path, mime_type, filename, fingerprint = nil)
        @path = path
        @mime_type = mime_type
        @filename = filename
        @fingerprint = fingerprint
      end
    end
  end
end
