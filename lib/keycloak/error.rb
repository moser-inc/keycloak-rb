module Keycloak
  class KeycloakError < StandardError; end

  class HttpResponseError < KeycloakError; end

  class HttpNotFoundError < KeycloakError; end
end
