module Keycloak
  require_relative 'keycloak/api'
  require_relative 'keycloak/realm'
  require_relative 'keycloak/version'

  class << self
    attr_accessor :realm, :host, :client, :secret
  end
end
