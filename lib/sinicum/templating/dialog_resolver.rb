module Sinicum
  module Templating
    # Private: Provides information about Magnolia dialogs.
    class DialogResolver
      include TemplatingUtils
      include Jcr::ApiClient

      def dialog_for_node(node)
        result = nil
        template = split_template_path(node.mgnl_template)
        path = "/_templating/dialogs/#{template[:type]}" \
          "/#{template[:module]}/#{template[:name]}"
        response = api_get(path)
        if response.ok?
          begin
            json = MultiJson.load(response.body)
            result = json["dialog"]
          rescue
            # nothing
          end
        end
        result
      end
    end
  end
end
