# encoding: utf-8
module Sinicum
  module HelperUtils
    DEFAULT_DOCUMENT_WORKSPACE = "dam"
    FINGERPRINT_REGEX = /.*-[0-9a-f]{32}(\..+)?$/

    protected

    def object_from_key_or_object(key_or_object, workspace = nil)
      mgnl_object_instance_cache(key_or_object, workspace) do
        object = nil
        if key_or_object.is_a?(Sinicum::Jcr::Node)
          object = key_or_object
        elsif key_or_object.is_a?(Symbol)
          object = value_from_content(Content::Aggregator.content_data, key_or_object)
          if Util.is_a_uuid?(object) && workspace
            object = Jcr::Node.find_by_uuid(workspace, object)
          end
        elsif Util.is_a_uuid?(key_or_object)
          node = Jcr::Node.find_by_uuid(workspace, key_or_object)
          object = node if node
        end
        object
      end
    end

    def mgnl_object_instance_cache(key_or_object, workspace, &block)
      cache_key = [mgnl_content_data, key_or_object, workspace]
      @__instance_cache ||= {}
      unless @__instance_cache.key?(cache_key)
        result = block.call
        @__instance_cache[cache_key] = result
      end
      @__instance_cache[cache_key]
    end

    def value_from_content(content_data, key)
      value = nil
      if content_data && content_data.respond_to?(key)
        value = content_data.send(key)
      elsif content_data && content_data.respond_to?(:[])
        value = content_data[key]
      end
      value
    end

    def meta_tag_value(key)
      if key && instance_variable_defined?("@#{key}")
        meta_value = instance_variable_get("@#{key}")
        if meta_value.is_a?(String)
          strip_tags(meta_value)
        else
          meta_value
        end
      elsif key && value_from_content(mgnl_content_data, key)
        mgnl_out(key, format: :strip_tags)
      else
        nil
      end
    end

    def meta_content_tag(options)
      content_tag(:title) do
        cms_title = nil
        if defined?(@meta_title) && @meta_title
          cms_title = @meta_title
        elsif defined?(@page_title) && @page_title
          cms_title = @page_title
        else
          cms_title = mgnl_out(:meta_title, format: :strip_tags).presence ||
            mgnl_out(:title, format: :strip_tags)
        end
        aggregated_title(cms_title, options)
      end
    end

    def aggregated_title(cms_title, options)
      title = ""
      title_delimiter = options[:title_delimiter] || " – "
      title << options[:title_prefix] if options[:title_prefix].present?
      if cms_title.present?
        title << title_delimiter if options[:title_prefix].present?
        title << cms_title
        title << title_delimiter if options[:title_suffix].present?
      end
      title << options[:title_suffix] if options[:title_suffix].present?
      title.html_safe
    end

    def meta_simple_meta_tag(attribute_name, key)
      result = nil
      meta_value = key
      meta_value = meta_tag_value(key) if key.is_a?(Symbol)
      if meta_value.present?
        result = tag(:meta, name: attribute_name, content: meta_value)
        result << "\n"
      end
      result
    end

    def add_missing_attributes(attributes, options)
      options.each do |key, value|
        attributes[key.to_sym] = value unless attributes.key?(key.to_sym)
      end
    end

    def image_attributes(image, options)
      attributes = {}
      attributes[:src] = adjust_to_asset_host(image.path(converter: options[:renderer]))
      attributes[:alt] = image.alt
      [:width, :height].each do |key|
        if options[key]
          attributes[key] = options[key]
        elsif options[key] != false && image.respond_to?(key)
          attributes[key] = image.send key, options[:renderer].presence || nil
        end
      end
      attributes
    end

    def link_tag_params(object, options)
      if object.respond_to?(:path)
        uri = object.path.gsub(%r{^/website/}, "/")
      else
        uri = object
      end
      uri = options[:prefix] + uri if options[:prefix]
      tag_params = { href: uri }
      tag_params[:class] = options[:class] if options[:class]
      tag_params[:style] = options[:style] if options[:style]
      tag_params[:target] = options[:target] if options[:target]
      tag_params
    end

    def adjust_to_asset_host(path)
      asset_host = defined?(compute_asset_host) ? compute_asset_host(path) : nil
      if asset_host.nil? || !fingerprint_in_asset_path(path)
        path
      else
        "#{asset_host}#{path}"
      end
    end

    def fingerprint_in_asset_path(path)
      !!(path && path =~ FINGERPRINT_REGEX)
    end

    def workspace(options)
      options[:workspace] || DEFAULT_DOCUMENT_WORKSPACE
    end

    def configure_for_srcset(attributes_hash)
      srcset_options = Sinicum::Imaging::Config.read_configuration.srcset_options
      if srcset_options.present?
        if (match = attributes_hash[:src].match(/(.+?)-(\h{32})(\.\w+)?$/)) &&
         attributes_hash[:width].is_a?(Numeric)
          attributes_hash[:srcset] = srcset_options.map { |e|  \
            "#{match[1]}_#{e[0]}-#{match[2]}#{match[3]} #{calculate_resulting_width(e[1],
            attributes_hash[:width])}w"}.join(", ")
        end
      end
      attributes_hash
    end

    private
    def calculate_resulting_width(srcset_option, original_picture_width)
      srcset_option = srcset_option[0...-1]
      result = original_picture_width*srcset_option.to_f
      result >= 1 ? result.to_i : 1
    end

  end
end
