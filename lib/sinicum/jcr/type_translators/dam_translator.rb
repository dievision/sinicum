module Sinicum
  module Jcr
    module TypeTranslators
      # Public: Identifies files stored in Magnolia's DAM workspace as Dam::Document
      # or Dam::Image types.
      class DamTranslator
        include TranslatorBase

        DOCUMENT_NODE = "jcr:content"
        IMAGE_TYPE_PREFIX = "image/"
        MIME_TYPE = "jcr:mimeType"

        WORKSPACE = "dam"
        NODE_TYPE = "mgnl:asset"

        def self.initialize_node(json)
          if jcr_primary_type(json) && workspace(json) == WORKSPACE &&
              jcr_primary_type(json) == NODE_TYPE
            if json[NODES][DOCUMENT_NODE]
              if json[NODES][DOCUMENT_NODE][PROPERTIES] &&
                  json[NODES][DOCUMENT_NODE][PROPERTIES][MIME_TYPE] &&
                  json[NODES][DOCUMENT_NODE][PROPERTIES][MIME_TYPE].index(IMAGE_TYPE_PREFIX) == 0
                ::Sinicum::Jcr::Dam::Image.new(json_response: json)
              else
                ::Sinicum::Jcr::Dam::Document.new(json_response: json)
              end
            end
          end
        end
      end
    end
  end
end
