module Keycloak
  module Cache

    def cached(*args, **kwargs)
      if defined?(Rails)
        Rails.cache.fetch(*args, **kwargs) do
          yield
        end
      else
        yield
      end
    end

  end
end
