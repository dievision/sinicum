module Sinicum
  module Logger
    require 'logger'
    @@logger = ::Logger.new(STDOUT)

    def self.included(base)
      base.extend(ClassMethods)
    end

    def logger
      if defined?(Rails) && Rails.logger
        return Rails.logger
      else
        return @@logger
      end
    end

    module ClassMethods
      def logger
        if defined?(Rails) && Rails.logger
          return Rails.logger
        else
          return @@logger
        end
      end
    end
  end
end
