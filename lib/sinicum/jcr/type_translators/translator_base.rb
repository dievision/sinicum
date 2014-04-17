module Sinicum
  module Jcr
    module TypeTranslators
      module TranslatorBase
        extend ActiveSupport::Concern

        META_NODE = "meta"
        NODES = "nodes"
        PROPERTIES = "properties"
        PRIMARY_TYPE = "jcr:primaryType"
        MGNL_TEMPLATE = "mgnl:template"
        WORKSPACE = "workspace"

        protected

        module ClassMethods
          def split_template_parts(json)
            mgnl_template(json).gsub('-', '_').split(":")
          end

          def jcr_primary_type(json)
            json[META_NODE][PRIMARY_TYPE] if json[META_NODE]
          end

          def workspace(json)
            json[META_NODE][WORKSPACE]
          end

          def mgnl_template(json)
            json[META_NODE][MGNL_TEMPLATE] if json[META_NODE] && json[META_NODE][MGNL_TEMPLATE]
          end

          def valid_json?(json)
            jcr_primary_type(json) && mgnl_template(json)
          end
        end
      end
    end
  end
end
