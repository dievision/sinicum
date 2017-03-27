module Sinicum
  module Imaging
    # Internal: Resizes an image to a predefined maximum size.
    class MaxSizeConverter
      include Converter
      include Sinicum::Logger

      attr_reader :format

      def initialize(configuration)
        super(configuration)
        @format = configuration['format'] || 'jpeg'
      end

      def convert(infile_path, outfile_path, extension, srcset_option = nil)
        if srcset_option.present?
          x = device_pixel_size_with_srcset(@x, srcset_option)
          y = device_pixel_size_with_srcset(@y, srcset_option)
        else
          x = device_pixel_size(@x)
          y = device_pixel_size(@y)
        end

        puts "x is #{x}"
        puts "y is #{y}"

        special = '-background transparent' if extension == 'png'

        if extension == 'gif'
          special = '-coalesce'
          layers = '-layers Optimize'
        end

        qo = srcset_option.present? ? "" : quality_option

        command = "convert #{infile_path} #{interlace_option(x, y, extension)} #{special} " \
          "#{qo}" +
          "-resize #{x}x#{y} #{layers} #{outfile_path}"
        puts "command is #{command.inspect}"
        `#{command}`

        optimize_png_outfile(outfile_path, extension)
      end

      def converted_size
        original_ratio = ratio(@document.width, @document.height)
        x = @x.to_f
        y = @y.to_f
        if @y != '' && x / original_ratio > y
          x = (y * original_ratio).round
        else
          y = (x / original_ratio).round
        end
        [x, y]
      end

    end
  end
end
