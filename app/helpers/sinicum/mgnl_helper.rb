# encoding: utf-8
module Sinicum
  module MgnlHelper
    include HelperUtils

    # Public: Returns the path for an object:
    #
    # - If the object is a Node, it returns the path of the node
    # - If the object is a UUID-String, it is resolved to the Node and the node's path
    #   is returned
    def mgnl_path(key_or_object, options = {})
      path = nil
      object = object_from_key_or_object(key_or_object, options[:workspace] || "website")
      if object
        if object.respond_to?(:path)
          path = object.path
          path = object.path(converter: options[:renderer]) if options.key?(:renderer)
        elsif object.is_a?(String)
          path = object.dup
        end
      elsif key_or_object.is_a?(String)
        path = key_or_object.dup
      end
      path
    end

    def mgnl_link(key_or_object, options = {}, &block)
      options = options.dup
      object = object_from_key_or_object(key_or_object, options[:workspace] || "website")
      object = key_or_object if object.nil? && key_or_object.is_a?(String)
      if object
        tag_params = link_tag_params(object, options)
        if block_given?
          content_tag(:a, tag_params) do
            capture(&block)
          end
        else
          content_tag(:a, nil, tag_params)
        end
      elsif block && options[:show_content]
        capture(&block)
      end
    end

    def mgnl_exists?(key_or_object, options = {})
      object = object_from_key_or_object(key_or_object, options[:workspace] || "website")
      !object.nil?
    end

    def mgnl_push(key_or_object, options = {})
      workspace = options[:workspace]
      pushed_content = object_from_key_or_object(key_or_object, workspace)
      if pushed_content
        Content::Aggregator.push(pushed_content) do
          yield
        end
      end
      nil
    end

    def mgnl_content_data
      Content::Aggregator.content_data
    end

    def mgnl_original_content
      Content::Aggregator.original_content
    end

    def mgnl_value(key)
      value_from_content(Content::Aggregator.content_data, key)
    end

    def mgnl_out(key, options = {})
      value = mgnl_value(key)
      value = "" if value.nil?
      value = value.to_s
      if options[:format] == :sanitize
        value = sanitize(value)
      elsif options[:format] == :strip_tags
        value = strip_tags(value)
      end
      value.html_safe
    end

    # Public: Displays the `<title>` tag and the `<meta>` tags for a page. The attributes
    # must follow the default naming conventions.
    #
    # Currently used attributes:
    #
    # * title
    # * meta_title
    # * meta_description
    # * meta_keywords
    # * meta_noindex
    # * meta_search_weight
    # * meta_search_boost
    #
    # Returns a String with all necessary `<meta>` tags and the `<title>` tag.
    def mgnl_meta(options = {})
      result = tag(
        :meta, :'http-equiv' => 'content-type', 'content' => 'text/html; charset=utf-8')
      result << "\n"
      result << meta_content_tag(options)
      result << "\n"
      result << meta_simple_meta_tag(:description, :meta_description)
      result << meta_simple_meta_tag(:keywords, :meta_keywords)
      result << meta_simple_meta_tag(:'X-Search-Weight', :meta_keywords)
      result << meta_simple_meta_tag(:'X-Search-Boost', :meta_search_boost)
      if meta_tag_value(:meta_noindex) || meta_tag_value(:robots) == 'false'
        result << meta_simple_meta_tag(:robots, 'noindex, nofollow')
      end
      result << meta_simple_meta_tag(:language, I18n.locale.to_s)
      result << meta_simple_meta_tag(:'DC.language', I18n.locale.to_s)
      result.html_safe
    end

    # Public: Iterates over an array with NavigationElement instances.
    #
    # base_node_or_path - The node or the path that should be the base of the
    #                     navigation
    # type              - Type of the navigation. Currently supports only
    #                     `:children`.
    # options           - Options for the navigation:
    #                     :depth - The depth of a `children` based navigation.
    # block             - The block with the content of the navigation. It
    #                     yields with an instance of a NavigationElement.
    def mgnl_navigation(base_node_or_path, type, options = {}, &block)
      elements = []
      if type == :children
        handler = Navigation::NavigationHandler.children(base_node_or_path, options[:depth])
        elements = handler.elements
      elsif type == :parents
        handler = Navigation::NavigationHandler.parents(base_node_or_path)
        elements = handler.elements
      end
      if block_given?
        elements.each do |element, status|
          block.call(element, status)
        end
      else
        elements
      end
    end

    def mgnl_jcr_global_cache_key
      @mgnl_jcr_global_cache_key ||= Sinicum::Jcr::Cache::GlobalCache.new.current_key
    end
  end
end
