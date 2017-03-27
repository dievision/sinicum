require 'digest/md5'
require 'open3'

module Sinicum
  module Imaging
    # Collection of helper methods common to Converters
    module Converter
      CONVERTER_VERSION = "1" # change to change Hash signature
      PNG_OPTIMIZER_SUFFIX = "-fs8.png"

      attr_writer :document

      def initialize(configuration)
        @x = configuration['x'] || ''
        @y = configuration['y'] || ''
        @render_type = configuration['render_type']
        @hires_factor = configuration['hires_factor'] || 1.0
        @configuration = configuration
      end

      # Computes a standard hash for a converted image, consisting of `x`, `y`, `render_type`
      # and `format`.
      #
      # @return [String] A hash based on the current converter's configuration
      def config_hash
        digest = Digest::MD5.hexdigest(
          "#{@x}-#{@y}-#{@hires_factor}-#{@render_type}-#{@format}-#{CONVERTER_VERSION}")
        digest
      end

      # Returns the interlace command line option if an image is large enough
      # (> 80px x 80px)
      #
      # @param [String, Fixnum] x the x size of an image
      # @param [String, Fixnum] y the y size of an image
      # @return [String] the command line option to interlace an image or an empty String
      def interlace_option(x, y, extension = nil)
        return "" if extension == 'gif'
        x.to_i * y.to_i > 80 * 80 ? "-interlace plane" : ""
      end

      def ratio(x, y)
        x.to_f / y.to_f
      end

      private

      def device_pixel_size(pixel)
        px = pixel.to_f * @hires_factor.to_f
        if px == 0
          ''
        else
          px.round
        end
      end

      def device_pixel_size_with_srcset(pixel, srcset_option)
        pixel = pixel.to_f
        px = pixel*srcset_option[0, srcset_option.length-1].to_f || 0
        if px == 0
          ''
        else
          px.round
        end
      end

      def quality_option
        "-quality 50" if @hires_factor && @hires_factor > 1.5
      end

      def optimize_png_outfile(outfile_path, extension)
        return unless extension == "png"
        cmd = "pngquant -- \"#{outfile_path}\""
        exec_command(cmd)
        cmd = "mv \"#{outfile_path}#{PNG_OPTIMIZER_SUFFIX}\" \"#{outfile_path}\""
        exec_command(cmd)
      rescue
        # Fail silently
      end

      def exec_command(command)
        status = nil
        Open3.popen2(command) do |stdin, stdout, wait_thr|
          status = wait_thr.value.exitstatus
        end
        if status != 0
          fail "Command '#{command}' failed with exit status #{status}"
        end
      end
    end
  end
end
