module Sinicum
  module Templating
    # Private: Handles the lookup and creation of Areas on the server.
    #
    # Returns an Array of Strings with the available components or nil if no
    # area could be identified.
    class AreaHandler
      include Jcr::ApiClient

      def lookup_or_create_area(base_node, area_name)
        result = nil
        if base_node && area_name.present?
          path = "/_templating/areas/initialize"
          response = api_post(
            path, body: {
              workspace: base_node.jcr_workspace,
              baseNodeUuid: base_node.uuid,
              areaName: area_name })
          if response.ok?
            begin
              json = MultiJson.load(response.body)
              result = json["availableComponents"]
            rescue => e
              Rails.logger.error("Could not lookup area: " + e.to_s)
              nil
            end
          end
        end
        result
      end
    end
  end
end
