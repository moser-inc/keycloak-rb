module Keycloak
  ServiceUserToken = Data.define(:value, :expires) do
    def expired?
      Time.now.to_i >= expires
    end
  end

  module ServiceUser
    include Cache

    def service_user_token
      raise 'This method requires a client secret' unless client_secret

      if @service_user_token.nil? || @service_user_token.expired?
        @service_user_token = cached("keycloak-service-user-#{client_id}", expires_in: 290) do
          fetch_service_user_token
        end
      end

      @service_user_token.value
    end

    private

    def fetch_service_user_token
      json = http_client.post_form(config['token_endpoint'], {
        grant_type: :client_credentials,
        client_id:,
        client_secret:
      })
      ServiceUserToken.new(
        json['access_token'], json['expires_in'] + Time.now.to_i
      )
    end
  end
end
