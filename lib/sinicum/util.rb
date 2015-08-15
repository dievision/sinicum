module Sinicum
  # Public: Collection of various utility methods.
  class Util
    UUID_REGEXP = /^[abcdef0-9]{8}-[abcdef0-9]{4}-[abcdef0-9]{4}-[abcdef0-9]{4}-[abcdef0-9]{12}$/i

    # rubocop:disable Style/PredicateName
    def self.is_a_uuid?(value)
      return false if value.nil? || !value.respond_to?('match')
      result = value.match(UUID_REGEXP)
      !!result
    end
  end
end
