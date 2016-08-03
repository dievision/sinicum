module Sinicum
  module MultisiteHelper
    include ActionView::Helpers::UrlHelper

    unless method_defined?(:sincum_url_for)
      alias_method :sincum_url_for, :url_for
    end

    def url_for(options = { })
      url = sincum_url_for(options)
      if session[:multisite_root]
        url.sub(/^(#{session[:multisite_root]})\//, '/')
      else
        url
      end
    end
  end
end
