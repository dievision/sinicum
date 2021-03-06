# encoding: utf-8
module Sinicum
  module MgnlImageHelper
    include HelperUtils

    def mgnl_asset_path(key_or_object = nil, options = {})
      options[:workspace] = "dam" if options[:workspace].nil?
      adjust_to_asset_host(mgnl_path(key_or_object, options))
    end

    def mgnl_img(key_or_object, options = {})
      attributes = mgnl_img_attributes(key_or_object, options)
      tag("img", attributes) if attributes
    end

    def mgnl_img_attributes(key_or_object, options = {})
      image = object_from_key_or_object(key_or_object, workspace(options))
      result = nil
      if image && image.is_a?(Sinicum::Jcr::Dam::Image)
        options = options.dup
        attributes = image_attributes(image, options)
        [:workspace, :renderer, :width, :height, :src, :alt].each do |attribute|
          options.delete(attribute)
        end
        add_missing_attributes(attributes, options)
        configure_for_srcset(attributes)
        attributes
      end
    end
  end
end
