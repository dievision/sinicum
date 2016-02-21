module Sinicum
  module Jcr
    module TypeTranslators
      # Public: Identifies a node as a `mgnl:page` or `mgnl:component` and finds
      # the class based on the node's template information.
      class ComponentTranslator
        include TranslatorBase

        PAGE_TYPE = "mgnl:page"
        COMPONENT_TYPE = "mgnl:component"

        def self.initialize_node(json)
          if valid_json?(json) &&
              (jcr_primary_type(json) == PAGE_TYPE || jcr_primary_type(json) == COMPONENT_TYPE)
            instance_from_template_name(json)
          end
        end

        def self.instance_from_template_name(json)
          class_name = split_template_parts(json).join("/").gsub("-", "_").classify
          class_name.constantize.new(json_response: json)
        rescue NameError
          nil
        end
      end
    end
  end
end
