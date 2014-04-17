module Sinicum
  module Templating
    module TemplatingUtils
      private

      def split_template_path(path)
        result = {}
        parts = path.split(":")
        result[:module] = parts[0]
        result[:type] = result_type(parts)        
        result[:name] = parts[1][parts[1].index("/") + 1, parts[1].length]
        result
      end

      def result_type(parts)
        if parts[1].index("pages/") == 0
          :page
        elsif parts[1].index("components/") == 0
          :component
        end
      end
    end
  end
end
