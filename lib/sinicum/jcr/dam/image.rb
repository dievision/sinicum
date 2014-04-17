module Sinicum
  module Jcr
    module Dam
      # Public: Wrapper around image files stored in Magnolia's DAM workspace.
      class Image < Document
        def width(converter_name = nil)
          fetch_value(:width, converter_name)
        end

        def height(converter_name = nil)
          fetch_value(:height, converter_name)
        end

        def alt
          self[:subject] || ""
        end

        private

        def image_size_converter(converter_name)
          @conv_cache ||= {}
          unless @conv_cache[converter_name]
            @conv_cache[converter_name] =
              Sinicum::Imaging::ImageSizeConverter.new(self, converter_name, workspace: "dam")
          end
          @conv_cache[converter_name]
        end

        def fetch_value(dimension, converter_name)
          value = nil
          if properties && properties[dimension]
            value = properties[dimension].to_i
            value = image_size_converter(converter_name).send(dimension) if converter_name
          end
          value
        end
      end
    end
  end
end
