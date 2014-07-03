module Sinicum
  module Jcr
    # Public: Base class to handle objects from the JCR store.
    class Node
      extend ActiveSupport::Inflector
      include ActiveModel::Conversion
      extend ActiveModel::Naming
      extend ActiveModel::Translation
      include ActiveModel::Validations
      include ActiveModel::AttributeMethods

      include NodeQueries
      include Mgnl4Compatibility

      ISO_8601_REGEX = /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}[+-]\d{2}:\d{2}/
      ISO_8601_DATE_REGEX = /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z/
      IMPLICIT_ARRAY_REGEX = /^\d+$/
      BOOL_TRUE_STRING_VALUE = "true"
      BOOL_FALSE_STRING_VALUE = "false"
      METADATA_NODE_NAME = "MetaData"
      META_KEY = "meta"
      PROPERTIES_KEY = "properties"
      NODES_KEY = "nodes"
      ARRAY_CHILD_NODE_PATTERN = /^\d+$/

      SETABLE_JCR_PROPERTIES = :jcr_path, :jcr_name, :jcr_primary_type, :jcr_primary_type,
        :jcr_super_types, :jcr_workspace, :jcr_mixin_node_types
      PROHIBITED_JCR_PROPERTIES = :uuid, :jcr_depth, :created_at, :updated_at, :lastaction_at
      SETABLE_MGNL_PROPERTIES = [:mgnl_template, :mgnl_created_by]
      PROHIBITED_MGNL_PROPERTIES = :mgnl_authorid, :mgnl_activatorid

      attr_reader *SETABLE_JCR_PROPERTIES, *PROHIBITED_JCR_PROPERTIES,
        *SETABLE_MGNL_PROPERTIES, *PROHIBITED_MGNL_PROPERTIES

      def initialize(params = {})
        if params.key?(:json_response)
          @__json_response = params[:json_response]
          initialize_properties_from_json
        else
          initialize_from_hash(params)
        end
      end

      def id
        uuid
      end

      def path(options = {})
        jcr_path
      end

      def to_model
        self
      end

      def persisted?
        !!@persisted
      end

      def [](property_name)
        result = nil
        property_key = property_name.to_s
        if jcr_properties && jcr_properties.key?(property_key)
          result = transform_jcr_types(jcr_properties[property_key])
        elsif node_cache.key?(property_key) || (jcr_nodes && jcr_nodes.key?(property_key))
          result = return_child_node(property_key)
        end
        result
      end

      def children
        children = []
        jcr_nodes.each do |child|
          next if child && child[0] == "MetaData"
          children << NodeInitializer.initialize_node_from_json(child[1])
        end
        children
      end

      def parent
        fetch_from_parent_cache do
          current_node_path = path.split("/")
          current_node_path.slice!(-1) if current_node_path.size > 1
          Sinicum::Jcr::Node.find_by_path(jcr_workspace, current_node_path.join("/"))
        end
      end

      def to_s
        "#{self.class.name}, uuid: '#{uuid}', path: '#{jcr_path}'"
      end

      def inspect
        properties = []
        jcr_properties.each_key { |key| properties << key } if jcr_properties
        nodes = []
        jcr_nodes.each_key { |key| nodes << key } if jcr_nodes
        to_s + ", properties: #{properties}, nodes: #{nodes}\n"
      end

      protected

      def jcr_properties
        @__json_response[PROPERTIES_KEY] if @__json_response
      end

      def jcr_nodes
        @__json_response[NODES_KEY] if @__json_response
      end

      private

      def initialize_properties_from_json
        meta_info = @__json_response[META_KEY]
        @uuid = meta_info["jcr:uuid"].freeze
        @jcr_path = meta_info["path"].freeze
        @jcr_name = meta_info["name"].freeze
        @jcr_primary_type = meta_info["jcr:primaryType"].freeze
        @jcr_super_types = meta_info["superTypes"].freeze
        @jcr_mixin_node_types = meta_info["mixinNodeTypes"].freeze
        @jcr_workspace = meta_info["workspace"].freeze
        @jcr_depth = meta_info["depth"].freeze
        @created_at = jcr_time_string_to_datetime(meta_info["mgnl:created"]).freeze
        @updated_at = jcr_time_string_to_datetime(meta_info["mgnl:lastModified"]).freeze
        @mgnl_template = meta_info["mgnl:template"].freeze
        @mgnl_created_by = meta_info["mgnl:createdBy"].freeze
        @persisted = true
        initialize_from_mgnl4_meta_data_node(meta_info)
      end

      def initialize_from_mgnl4_meta_data_node(meta_info)
        @created_at = jcr_time_string_to_datetime(meta_info["jcr:created"]).freeze
      end

      def initialize_from_hash(hash)
        @__json_response = { PROPERTIES_KEY => {} }
        hash.each do |key, value|
          check_for_allowed_properties(key)
          unless set_system_property(key, value)
            @__json_response[PROPERTIES_KEY][key.to_s] = value
          end
        end
      end

      def check_for_allowed_properties(key)
        key_sym = key.to_sym
        if PROHIBITED_JCR_PROPERTIES.include?(key_sym) ||
            PROHIBITED_MGNL_PROPERTIES.include?(key_sym)
          fail Error.new("Property '#{key_sym}' cannot be set manually. It has to be generated " +
            "when fetching a node from the JCR repository")
        end
      end

      def set_system_property(key, value)
        key_sym = key.to_sym
        if SETABLE_JCR_PROPERTIES.include?(key_sym) || SETABLE_MGNL_PROPERTIES.include?(key_sym)
          instance_variable_set(:"@#{key}", value)
          return true
        end
        false
      end

      def return_child_node(node_key)
        fetch_from_node_cache(node_key) do
          value = nil
          child_node = jcr_nodes[node_key]
          if implicit_array?(node_key)
            value = convert_implicit_array(node_key)
          else
            value = NodeInitializer.initialize_node_from_json(child_node)
          end
          value
        end
      end

      def transform_jcr_types(value)
        result = jcr_time_string_to_datetime(value)
        result = mgnl_boolean_string_to_boolean(result)
        result
      end

      def implicit_array?(node_key)
        has_array_pattern = false
        child_node = jcr_nodes[node_key]
        primary_type = nil
        if child_node && child_node["meta"]
          primary_type = child_node["meta"]["jcr:primaryType"]
        end
        if child_node && child_node[NODES_KEY] && child_node[NODES_KEY].size > 0 &&
            primary_type != "mgnl:area"
          child_nodes = child_node[NODES_KEY]
          child_nodes.each_key do |key|
            next if key == METADATA_NODE_NAME
            if key =~ IMPLICIT_ARRAY_REGEX
              has_array_pattern = true
            else
              has_array_pattern = false
              break
            end
          end
        end
        has_array_pattern
      end

      def convert_implicit_array(node_key)
        result = []
        child_node = jcr_nodes.delete(node_key)
        child_node[NODES_KEY].each_key do |key|
          next if key == METADATA_NODE_NAME
          child = child_node[NODES_KEY].delete(key)
          result << NodeInitializer.initialize_node_from_json(child)
        end
        result
      end

      def jcr_time_string_to_datetime(value)
        result = nil
        if value && value =~ ISO_8601_REGEX
          result = DateTime.parse(value)
        elsif value && value =~ ISO_8601_DATE_REGEX
          result = Time.parse(value).getlocal.to_date
        else
          result = value
        end
        result
      end

      def fetch_from_node_cache(node_key, &block)
        result = nil
        if node_cache.key?(node_key)
          result = node_cache[node_key]
        else
          result = yield
          node_cache[node_key] = result
        end
        result
      end

      def node_cache
        @__node_cache ||= {}
      end

      def fetch_from_parent_cache(&block)
        result = nil
        if parent_cache
          result = parent_cache
        else
          result = yield
          @__parent_cache = result
        end
        result
      end

      def parent_cache
        @__parent_cache
      end

      def mgnl_boolean_string_to_boolean(value)
        result = value
        if value == BOOL_TRUE_STRING_VALUE
          result = true
        elsif value == BOOL_FALSE_STRING_VALUE
          result = false
        end
        result
      end
    end
  end
end
