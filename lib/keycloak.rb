module Keycloak
  require_relative 'keycloak/realm'
  require_relative 'keycloak/version'

  class << self
    attr_accessor :realm, :host, :client, :secret, :logger
  end

  @logger = Logger.new($stdout)
end
