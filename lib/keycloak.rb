module Keycloak
  require_relative 'keycloak/cache'
  require_relative 'keycloak/realm'
  require_relative 'keycloak/version'

  class << self
    attr_accessor :realm, :host, :client, :secret, :logger, :cache
  end

  @logger = Logger.new($stdout)
  @cache = defined?(Rails) ? Keycloak::RailsCache.new : Keycloak::NullCache.new
end
