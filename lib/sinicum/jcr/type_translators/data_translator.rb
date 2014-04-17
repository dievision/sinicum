module Sinicum
  module Jcr
    module TypeTranslators
      # Public: Identifies nodes in the data module and assigns the matching
      # classes to them.
      class DataTranslator
        include TranslatorBase
        DEFAULT_TYPES = ["mgnl:content", "mgnl:contentNode"]

        WORKSPACE = "data"

        def self.initialize_node(json)
          if workspace(json) == WORKSPACE && jcr_primary_type(json) && no_default_type?(json)
            instance_from_primary_type(json)
          end
        end

        def self.no_default_type?(json)
          !DEFAULT_TYPES.include?(jcr_primary_type(json))
        end

        def self.instance_from_primary_type(json)
          clazz = jcr_primary_type(json).classify
          clazz.constantize.new(json_response: json)
        rescue NameError
          nil
        end
      end
    end
  end
end
