module Sinicum
  module Imaging
    # Internal: Simple converter that simply serves a copy of the original file.
    class DefaultConverter
      include Converter
      include Sinicum::Logger

      def initialize(configuration)
      end

      def convert(infile_path, outfile_path)
        `cp #{infile_path} #{outfile_path}`
      end

      def format
        ".#{@document[:document][:extension]}" if @document && @document[:document]
      end
    end
  end
end
