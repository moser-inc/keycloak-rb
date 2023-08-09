module Keycloak
  class KeycloakError < StandardError; end

  class HttpResponseError < KeycloakError
    attr_reader :response

    def initialize(response)
      @response = response

      super(response.message)
    end

    def body
      @response.body
    end

    def json
      return nil if body.blank?

      JSON.parse(body)
    end
  end

  class HttpNotFoundError < HttpResponseError; end
end
