module Keycloak
  class KeycloakError < StandardError; end

  class HttpResponseError < KeycloakError; end

  class ClientSecretError < KeycloakError
    def initialize
      super 'This action requires a Keycloak client ID and secret be configured'
    end
  end
end
