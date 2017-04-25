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

      attr_reader :fingerprint, :srcset_option

      # Render the image from path `original_path` with the renderer `renderer`
      #
      # @param [String] original_path The original path of the image.
      # @param [String] renderer The name of the renderer
      # @return [RenderResult] The result of the conversion
      def self.rendered_resource(original_path, extension, renderer, fingerprint, srcset_option = "", workspace = nil)
        imaging = Imaging.new(original_path, extension, renderer, fingerprint, srcset_option, workspace)
        imaging.fetch_image
      end

      def initialize(original_path, extension, renderer, fingerprint, srcset_option, workspace = nil)
        @original_path = original_path
        @extension = extension
        @renderer = renderer
        @srcset_options = config_data.apps["dam"]["srcset_options"]
        @srcset_option = srcset_option.nil? ? "" : srcset_option
        @fingerprint = fingerprint
        @workspace = workspace
      end

      def fetch_image
        result = nil
        @image, @doc = find_image_objects_by_path(@original_path)

        if @image && @doc
          if convert_file?
            result = @srcset_options.present? ? perform_srcset_conversion : perform_conversion
          elsif @srcset_option.present?
            result = RenderResult.new(
              file_rendered(@srcset_option), mime_type_for_document, @doc[:fileName], fingerprint)
          else
            result = RenderResult.new(
              file_rendered, mime_type_for_document, @doc[:fileName], fingerprint)
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
      def file_rendered(srcset_affix = "")
        @_file_rendered ||= Hash.new do |h, srcset_affix|
          h[srcset_affix] = File.join(config_data.file_dir, "/" + @renderer + "-" +
          converter.config_hash + "_" + srcset_affix + "-" + @image.fingerprint + "." +
          converter.format)
        end
        @_file_rendered[srcset_affix]
      end

      # Finds the image objects by path
      #
      # @param [String] original_path The original path
      # @return [Array] An `Array` in the form `[Image, Document]`
      def find_image_objects_by_path(original_path)
        result = [nil, nil]
        image = Sinicum::Jcr::Node.find_by_path(@workspace, original_path)
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
              file_rendered, @doc["jcr:mimeType"], @doc[:fileName], fingerprint)
          rescue => e
            FileUtils.rm(out_file.path) if File.exist?(out_file.path)
            raise e
          ensure
            FileUtils.rm(in_file.path) if File.exist?(in_file.path)
          end
        }
      end

      #same as perform_conversion but with scrset images as defined in imaging.yml beeing generated as well
      def perform_srcset_conversion
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
            out_index = out_file.path.rindex("-out-")

            @srcset_options.each do |srcset_option|
              outfile_path = out_file.path[0, out_index]+srcset_option.first+out_file.path[out_index..-1]
              convert(in_file.path, outfile_path, nil, srcset_option.second)
              FileUtils.mv(outfile_path, file_rendered(srcset_option.first))
              FileUtils.chmod(0644, file_rendered(srcset_option.first))
            end
            RenderResult.new(
              file_rendered(@srcset_option), @doc["jcr:mimeType"], @doc[:fileName], fingerprint)
          rescue => e
            FileUtils.rm(out_file.path) if File.exist?(out_file.path)
            raise e
          ensure
            FileUtils.rm(in_file.path) if File.exist?(in_file.path)
          end
        }
      end

      def convert(infile_path, outfile_path, extension = nil, srcset_option = nil)
        converter.convert(infile_path, outfile_path, @doc[:extension], srcset_option)
      end

      def write_doc_to_tempfile(tempfile)
        begin
          Sinicum::Jcr::Node.stream_attribute(@doc.jcr_workspace, @doc.path, "jcr:data", tempfile)
        rescue => e
          logger.error("Cannot write to tempfile: " + e.to_s)
        end
      end

      def mime_type_for_document
        Rack::Mime.mime_type("." + @image.extension)
      end

      def convert_file?
        last_modified = @doc["jcr:lastModified"]
        # File.size == 0 is related to a (temporary?) bug on one server
        # should be possible to remove
        if @srcset_options.present?
          result = false
          @srcset_options.each do |srcset_option|
            result = result || !File.exist?(file_rendered(srcset_option.first)) ||
              File.mtime(file_rendered(srcset_option.first)) < last_modified ||
              File.size(file_rendered(srcset_option.first)) == 0
          end
          result
        else
          !File.exist?(file_rendered) || File.mtime(file_rendered) < last_modified || File.size(file_rendered) == 0
        end
      end

      def random
        @random ||= "#{Process.pid}-#{rand(1_000_000_000)}"
      end

      def config_data
        Config.read_configuration
      end

      def converter
        conv = config_data.converter(@renderer, @srcset_options)
        conv.document = @image if conv
        conv
      end
    end

    # Internal: Simple wrapper around imaging results.
    class RenderResult
      attr_accessor :path, :mime_type, :filename, :fingerprint, :srcset_option

      def initialize(path, mime_type, filename, srcset_option = "", fingerprint = nil)
        @path = path
        @mime_type = mime_type
        @filename = filename
        @fingerprint = fingerprint
        @srcset_option = srcset_option
      end
    end
  end
end
