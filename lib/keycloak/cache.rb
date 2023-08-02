module Keycloak

  class NullCache
    def fetch(...)
      yield
    end
  end

  class RailsCache
    def fetch(...)
      Rails.cache.fetch(...)
    end
  end
end
