# encoding: utf-8
module Sinicum
  module TaglibHelper5
    include Templating::TemplatingUtils

    def mgnl_init
      return unless mgnl_render_bars && mgnl_original_content
      result = "<!-- begin js and css added by @cms.init -->\n"
      result << content_tag(:meta, nil, name: "gwt:property", content: "locale=en") + "\n"
      result << comment_tag(
        :'cms:page',
        nil,
        content: component_path(mgnl_original_content.jcr_workspace, mgnl_original_content.path),
        dialog: dialog_for_node(mgnl_original_content),
        preview: mgnl_preview_mode)
      result << "\n"

      result << "<!-- end js and css added by @cms.init -->"

      result.html_safe
    end

    def mgnl_area(name, options = {})
      area_name = name
      result = nil
      if area_name.present?
        available_components = initialize_area(mgnl_content_data, area_name)
        if options[:component_whitelist]
          available_components = available_components & options[:component_whitelist]
        end
        if available_components
          result = mgnl_comment_tag(
            :'cms:area',
            content: "#{mgnl_content_data.jcr_workspace}:#{mgnl_content_data.jcr_path}/" \
            "#{area_name}",
            name: area_name,
            availableComponents: available_components.join(","),
            type: "list",
            label: area_name,
            inherit: "false",
            optional: "false",
            showAddButton: "true",
            showNewComponentArea: "true",
            description: area_name) do
            mgnl_render_component(area_name.to_sym, options)
          end
          result = result.html_safe if result
        elsif !mgnl_render_bars
          result = mgnl_render_component(area_name.to_sym, options)
        end
      end
      result
    end

    def mgnl_components
      mgnl_content_data.children
    end

    def mgnl_render_component(key_or_object, options = {})
      result = nil
      node = object_from_key_or_object(key_or_object)
      if node
        mgnl_push(node) do
          if node.jcr_primary_type == "mgnl:component" && mgnl_render_bars
            result = mgnl_comment_tag(
              :'cms:component',
              content: "#{node.jcr_workspace}:#{node.jcr_path}",
              dialog: dialog_for_node(node),
              label: node.mgnl_template) do
              begin
                render create_render_params(node, options)
              rescue ActionView::MissingTemplate => e
                render_missing_template(node, e)
              end
            end
            result = result.html_safe
          else
            begin
              result = render create_render_params(node, options)
            rescue ActionView::MissingTemplate => e
              result = render_missing_template(node, e)
            end
          end
        end
      end
      result
    end

    def mgnl_render_bars
      request.headers["HTTP_X_MGNL_ADMIN"].present? && !Rails.env.production?
    end

    def mgnl_preview_mode
      request.headers["HTTP_X_MGNL_PREVIEW"] == "true" || !mgnl_render_bars
    end

    private

    def render_missing_template(node, error)
      type = node.jcr_primary_type == "mgnl:area" ? "area" : "component"
      unless Rails.env.production?
        content_tag(:div, nil, class: "mgnl-missing-template-error") do
          content_tag(:p, nil, class: "mgnl-message") do
            "Missing partial for #{type} ".html_safe +
            content_tag(:code) do
              node.mgnl_template.presence || node.jcr_name
            end + "."
          end
        end
      end
    end

    def create_render_params(node, options)
      params = { partial: partial_name_for_node(node) }
      params[:locals] = options[:locals] if options.key?(:locals)
      params
    end

    def partial_name_for_node(node)
      partial_name = nil
      if node
        if node.mgnl_template
          partial_name = node.mgnl_template.gsub(":", "/")
        elsif node.jcr_primary_type == "mgnl:area"
          partial_name = "areas/#{node.jcr_name}"
        end
      end
      partial_name = "mgnl/" + partial_name if partial_name
      partial_name
    end

    def dialog_for_node(node)
      @dialog_resolver ||= Templating::DialogResolver.new
      @dialog_resolver.dialog_for_node(node)
    end

    def comment_tag(name, content_or_options_with_block = nil, options = nil, escape = true, &block)
      result = content_tag(name, content_or_options_with_block, options, escape, &block)
      result.gsub!("<", "<!-- ")
      result.gsub!(">", " -->\n")
      result
    end

    def initialize_area(base_node, area_name)
      if mgnl_render_bars
        @area_handler ||= Templating::AreaHandler.new
        @area_handler.lookup_or_create_area(base_node, area_name)
      end
    end

    def mgnl_comment_tag(tag, options = {}, &block)
      return yield if mgnl_preview_mode
      result = "<!-- "
      result << tag.to_s
      options.each do |key, value|
        result << " #{escape_once(key.to_s)}=\"#{escape_once(value.to_s)}\""
      end
      result << " -->\n"
      if block_given?
        yield_result = yield
        result << yield_result if yield_result.present?
      end
      result << "\n<!-- /#{tag} -->"
    end

    def component_path(component, path)
      "#{component}:#{path}"
    end
  end
end
