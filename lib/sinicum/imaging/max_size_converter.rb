module Sinicum
  module Imaging
    # Internal: Resizes an image to a predefined maximum size.
    class MaxSizeConverter
      include Converter
      include Sinicum::Logger

      attr_reader :format

      def initialize(configuration)
        if !configuration['format'] || (!configuration['x'] && !configuration['y'])
          fail ArgumentError.new("Converter requires the arguments: format, x, y")
        end
        super(configuration)
        @format = configuration['format'] || 'jpeg'
      end

      def convert(infile_path, outfile_path, extension)
        x = device_pixel_size(@x)
        y = device_pixel_size(@y)

        special = '-background transparent' if extension == 'png'

        if extension == 'gif'
          special = '-coalesce'
          layers = '-layers Optimize'
        end

        command = "convert #{infile_path} #{interlace_option(x, y, extension)} #{special} " \
          "#{quality_option}" +
          " -resize #{x}x#{y} #{layers} #{outfile_path}"
        `#{command}`

        optimize_png_outfile(outfile_path, extension)
      end

      def converted_size
        original_ratio = ratio(@document.width, @document.height)
        x = @x.to_f
        y = @y.to_f
        if @y != '' && ((x / original_ratio > y) || @x == '')
          x = (y * original_ratio).round 
        else
          y = (x / original_ratio).round
        end
        [x, y]
      end

    end
  end
end
