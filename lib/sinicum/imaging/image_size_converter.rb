module Sinicum
  module Imaging
    # Public: Calculates the size of an image based on the converter used to
    # render the image.
    class ImageSizeConverter
      DEFAULT_WORKSPACE = "dam"

      def initialize(image_or_jcr_path, converter_name, options = {})
        if image_or_jcr_path.is_a?(String)
          workspace = options[:workspace].presence || DEFAULT_WORKSPACE
          @image = Sinicum::Jcr::Node.find_by_path(workspace, image_or_jcr_path)
        elsif image_or_jcr_path.respond_to?(:width) && image_or_jcr_path.respond_to?(:height)
          @image = image_or_jcr_path
        end
        @converter_name = converter_name
      end

      def width
        unless defined?(@width)
          if converter.respond_to?(:converted_size)
            @width = converter.converted_size[0]
          else
            @width = @image.width
          end
        end
        @width
      end

      def height
        unless defined?(@height)
          if converter.respond_to?(:converted_size)
            @height = converter.converted_size[1]
          else
            @height = @image.height
          end
        end
        @height
      end

      private

      def converter
        unless defined?(@converter)
          conf = Config.read_configuration
          @converter = conf.converter(@converter_name)
          @converter.document = @image if @converter
        end
        @converter
      end
    end
  end
end
