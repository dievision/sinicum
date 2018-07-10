# encoding: utf-8

module Sinicum
  module ControllerBase
    HTML_SUFFIX = ".html"
    extend ActiveSupport::Concern
    include Controllers::CacheAware

    included do
      prepend_before_action ::Sinicum::Controllers::GlobalStateCache
      prepend_before_action :remove_html_suffix
      after_action ::Sinicum::Controllers::GlobalStateCache
      alias_method :original_rails_render, :render
      alias_method :render, :render_with_sinicum
    end

    def index
      cms_render
    end

    def render_with_sinicum(options = {}, locals = {}, &block)
      path = options[:content_path] ? options[:content_path] : content_path
      find_original_content_for_path(path)
      unless redirect_redirect_page
        check_for_content!
        if options[:text].nil? && options[:layout].nil?
          options[:layout] = layout_file_name_or_fallback
        end
        if block_given?
          original_rails_render(options, locals, block)
        else
          original_rails_render(options, locals)
        end
      end
    end

    # Deprecated!
    def cms_render
      client_cache_control
      render_with_sinicum inline: "", use_sinicum_template_layout: true
    end

    protected

    def content_path
      request.path
    end

    def find_original_content_for_path(path = content_path)
      original_content = Content::WebsiteContentResolver.find_for_path(path)
      Content::Aggregator.original_content = original_content
    end

    # Constructs the name of the layout file. Per default: Name of the template without special
    # characters and spaces. Override in subclasses.
    #
    # @return [String] the layout filename (without 'html.erb')
    def layout_file_name
      layout = "application"
      fail unless Content::Aggregator.original_content
      prepare_layout(layout)
    end

    private

    def prepare_layout(layout)
      if Content::Aggregator.original_content &&
          Content::Aggregator.original_content.mgnl_template
        layout = Content::Aggregator.original_content.mgnl_template.dup
      end
      layout = handle_mgnl45_names(layout)
      layout = handle_umlauts(layout)
      layout.downcase!
      layout.gsub!(/\s/, '_')
      layout.gsub!(/[^\w\/-]/, '')
      add_sinicum_layout_prefix(layout)
    end

    def add_sinicum_layout_prefix(layout)
      if self.class.sinicum_layout_prefix.present?
        layout = self.class.sinicum_layout_prefix + "/" + layout
      end
      layout
    end

    def check_for_content!
      unless Sinicum::Content::Aggregator.content_data
        fail ActionController::RoutingError.new("Page not found.")
      end
    end

    def handle_mgnl45_names(layout_name)
      result = layout_name
      if result.index(":pages/")
        parts = layout_name.split(":")
        result = parts[0] + "/"
        result << parts[1][":pages/".size - 1, parts[1].size]
      end
      result
    end

    def redirect_redirect_page
      return false if request.headers["HTTP_X_MGNL_ADMIN"].present?
      page = ::Sinicum::Content::Aggregator.content_data
      if redirect_page_45?(page) || redirect_page_44?(page)
        redirect_target = page[:redirect_link]
        redirect_status = page[:redirect_status] || 302
        if Sinicum::Util.is_a_uuid?(redirect_target)
          redirect_target = Sinicum::Jcr::Node.find_by_uuid("website", redirect_target).try(:path)
          if redirect_target && page[:anchor].present?
            redirect_target = "#{redirect_target}#{page[:anchor]}"
          end
        end
        redirect_to url_for(redirect_target), status: redirect_status
        return true
      end
      return false
    end

    def redirect_page_44?(page)
      magnolia_template_exists?(page) && page.mgnl_template == "redirect" && page[:redirect_link]
    end

    def redirect_page_45?(page)
      magnolia_template_exists?(page) &&
        page.mgnl_template.index("pages/redirect") &&
        (page[:redirect_link] || page[:external_redirect_link])
    end

    def magnolia_template_exists?(page)
      page && page.mgnl_template
    end

    # Determines the name of the layout file that is _actually_ used by the controller.
    # By default it's the result of `layout_file_name`. If this file cannot be found, a
    # default replacement (`application`) is used
    #
    # @return [String] the name of the layout file actually used
    def layout_file_name_or_fallback
      ActionController::Base.view_paths.each do |path|
        ActionView::Template::Handlers.extensions.each do |engine_suffix|
          format = params[:format].presence || "html"
          file_in_path = File.join(
            path.to_s, "layouts", "#{layout_file_name}.#{format}.#{engine_suffix}"
          )
          return layout_file_name if File.exist?(file_in_path)
        end
      end
      fallback = "application"
      if self.class.sinicum_layout_prefix.present?
        fallback = self.class.sinicum_layout_prefix + "/" + fallback
      end
      fallback
    end

    def remove_html_suffix
      if request.get? && request.path =~ /#{HTML_SUFFIX}$/i
        new_path = request.path[0, request.path.length - HTML_SUFFIX.length]
        if request.query_string && !request.query_string.blank?
          new_path << "?#{request.query_string}"
        end
        redirect_to url_for(new_path)
      end
    end

    def find_content_for_request
      find_original_content_for_path(content_path)
      yield
    end

    def handle_umlauts(layout)
      if !layout.respond_to?(:encode)
        @_iconv ||= Iconv.new("US-ASCII//IGNORE", "UTF-8")
        layout = @_iconv.iconv(layout)
      elsif layout
        layout = layout.encode(
          "US-ASCII", undef: :replace, invalid: :replace, replace: '-'
        )
      end
      layout
    end

    module ClassMethods
      attr_accessor :sinicum_layout_prefix
    end
  end
end
