require 'active_support/core_ext'
require 'sprockets/railtie'
require 'sinicum/engine'

module Sinicum
  require 'sinicum/logger'

  require 'sinicum/content/aggregator'
  require 'sinicum/content/website_content_resolver'

  require 'sinicum/util'

  require 'sinicum/imaging'
  require 'sinicum/imaging/config'
  require 'sinicum/imaging/converter'
  require 'sinicum/imaging/imaging'
  require 'sinicum/imaging/max_size_converter'
  require 'sinicum/imaging/resize_crop_converter'
  require 'sinicum/imaging/default_converter'
  require 'sinicum/imaging/image_size_converter'
  require 'sinicum/imaging/imaging_middleware'
  require 'sinicum/imaging/imaging_file'

  require 'sinicum/multisite/multisite_middleware'
  require 'sinicum/multisite/utils'

  require 'sinicum/jcr/jcr_configuration'
  require 'sinicum/jcr/configuration_reader'
  require 'sinicum/jcr/api_queries'
  require 'sinicum/jcr/api_client'
  require 'sinicum/jcr/query_sanitizer'
  require 'sinicum/jcr/node_queries'
  require 'sinicum/jcr/mgnl4_compatibility'
  require 'sinicum/jcr/node'
  require 'sinicum/jcr/node_initializer'

  require 'sinicum/jcr/dam/document'
  require 'sinicum/jcr/dam/image'

  require 'sinicum/jcr/type_translators/translator_base'
  require 'sinicum/jcr/type_translators/default_translator'
  require 'sinicum/jcr/type_translators/component_translator'
  require 'sinicum/jcr/type_translators/imaging_app_translator'
  require 'sinicum/jcr/type_translators/data_translator'
  require 'sinicum/jcr/type_translator'

  require 'sinicum/jcr/cache/global_cache'

  require 'sinicum/templating/templating_utils'
  require 'sinicum/templating/dialog_resolver'
  require 'sinicum/templating/area_handler'

  require 'sinicum/navigation/navigation_element'
  require 'sinicum/navigation/navigation_status'
  require 'sinicum/navigation/default_navigation_element'
  require 'sinicum/navigation/navigation_handler'
  require 'sinicum/navigation/navigation_element_list'

  require 'sinicum/cache/thread_local_cache'
  require 'sinicum/cache/thread_local_cache_middleware'
end
