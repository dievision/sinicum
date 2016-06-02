module Sinicum
  module Jcr
    module Dam
      # Public: Wrapper around documents stored in Magnolia's DAM workspace.
      class Document < ::Sinicum::Jcr::Node
        FINGERPRINT_VERSION = "2"

        %w(name subject description type).each do |field|
          define_method(field) { self[field.to_sym] }
        end

        # Returns a node, which contains the properties of the document
        def properties
          self[:'jcr:content'] if self[:'jcr:content']
        end

        def path(options = {})
          app = ::Sinicum::Imaging.app_from_workspace(jcr_workspace)
          converter_name = options[:converter].presence ||
            ::Sinicum::Imaging.default_converter_name
          path = "#{app['imaging_prefix']}/#{converter_name}#{super}-#{fingerprint}"
          if properties && properties[:extension].present?
            path << ".#{properties[:extension]}"
          end
          path
        end

        def file_size
          properties[:size].to_i if properties
        end

        def file_name
          [properties[:fileName], properties[:extension]].join(".") if properties
        end

        def extension
          properties[:extension] if properties
        end

        def mime_type
          properties[:'jcr:mimeType'] if properties
        end

        def date
          self[:date1] || updated_at
        end

        def fingerprint
          unless @fingerprint
            attributes = [
              FINGERPRINT_VERSION, jcr_path, id, properties[:'jcr:lastModified'],
              properties[:'jcr:lastModifiedBy'], properties[:size]]
            @fingerprint = Digest::MD5.hexdigest(attributes.join("-"))
          end
          @fingerprint
        end
      end
    end
  end
end
