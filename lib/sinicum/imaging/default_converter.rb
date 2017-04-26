module Sinicum
  module Imaging
    # Internal: Simple converter that simply serves a copy of the original file.
    class DefaultConverter
      include Converter
      include Sinicum::Logger

      def initialize(configuration)
      end

      def convert(infile_path, outfile_path, extension = nil, srcset_option = nil)
        `cp #{infile_path} #{outfile_path}`
      end

      def format
        if @document
          if @document[:'jcr:content']
            ".#{@document[:'jcr:content'][:extension]}"
          elsif @document[:document]
            ".#{@document[:document][:extension]}"
          end
        end
      end
    end
  end
end
