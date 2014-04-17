module Sinicum
  module Jcr
    module QuerySanitizer
      private

      def sanitize_query(language, query, parameters = nil)
        return query unless parameters && parameters.size > 0

        base_query = query.to_s.dup
        parameters.each_key do |key|
          original_value = parameters[key]
          san_value = escape_for_query(original_value)
          key_pattern = ":#{key}"
          base_query.gsub!(key_pattern, san_value)
        end
        base_query
      end

      def escape_for_query(unsafe_string)
        unsafe_string.gsub('\'', '\'\'')
      end
    end
  end
end
