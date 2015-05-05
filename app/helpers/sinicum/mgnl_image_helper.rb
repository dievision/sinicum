# encoding: utf-8
module Sinicum
  module MgnlImageHelper
    include HelperUtils

    def mgnl_asset_path(key_or_object = nil, options = {})
      options[:workspace] = "dam"
      mgnl_path(key_or_object, options)
    end

    def mgnl_img(key_or_object, options = {})
      image = object_from_key_or_object(key_or_object, workspace(options))
      result = nil
      if image
        options = options.dup
        attributes = image_attributes(image, options)
        [:workspace, :renderer, :width, :height, :src, :alt].each do |attribute|
          options.delete(attribute)
        end
        add_missing_attributes(attributes, options)
        result = tag("img", attributes)
      end
      result
    end
  end
end
