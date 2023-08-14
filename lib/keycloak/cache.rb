module Keycloak

  class NullCache
    def fetch(...)
      yield
    end
  end

  class RailsCache
    def fetch(*args, **kwargs, &block)
      kwargs[:race_condition_ttl] = 5

      Rails.cache.fetch(*args, **kwargs, &block)
    end
  end
end
