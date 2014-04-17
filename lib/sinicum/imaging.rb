module Sinicum
  module Imaging
    DEFAULT_CONVERTER_NAME = "default"
    DEFAULT_IMAGING_PREFIX = "/damfiles"
    DEFAULT_IMAGING_DMS_PREFIX = "/dmsfiles"
    DEFAULT_DAM_PREFIX = "/dam"
    DEFAULT_DMS_PREFIX = "/dms"

    def self.default_converter_name
      DEFAULT_CONVERTER_NAME
    end

    def self.path_prefix_mgnl4
      DEFAULT_IMAGING_DMS_PREFIX
    end

    def self.path_prefix
      DEFAULT_IMAGING_PREFIX
    end

    def self.dam_path_prefix
      DEFAULT_DAM_PREFIX
    end

    def self.dms_path_prefix
      DEFAULT_DMS_PREFIX
    end
  end
end
