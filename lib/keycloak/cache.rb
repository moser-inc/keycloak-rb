module Keycloak
  module Cache

    def cached(...)
      if defined?(Rails)
        Rails.cache.fetch(...)
      else
        yield
      end
    end

  end
end
