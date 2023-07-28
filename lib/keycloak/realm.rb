require 'net/http'
require 'jwt'
require_relative 'error'
require_relative 'http_client'

module Keycloak
  class Realm
    attr_reader :host, :realm, :client_id, :client_secret, :http_client

    def initialize(host: Keycloak.host,
      realm: Keycloak.realm,
      client: Keycloak.client,
      secret: Keycloak.secret)
      @host = host
      @realm = realm
      @client_id = client
      @client_secret = secret
      @http_client = HttpClient.new
      @service_user_token = nil
    end

    def config
      @config ||= http_client.get(
        "https://#{host}/realms/#{realm}/.well-known/openid-configuration",
        expires_in: 3600
      )
      @config
    end

    def jwks_certificates
      @jwks_certificates ||= http_client.get(config['jwks_uri'], expires_in: 3600)
      @jwks_certificates
    end

    def decode(token)
      decoded = JWT.decode(token, nil, true, { algorithms: ['RS256'], jwks: lambda do |options|
        @cached_keys = nil if options[:invalidate]
        @cached_keys ||= { keys: jwks_certificates['keys'] }
      end })

      decoded&.first
    end

    def refresh(refresh_token)
      http_client.post_form(config['token_endpoint'], {
        grant_type: :refresh_token,
        client_id:,
        refresh_token:
      })
    end

    [:get, :post, :put].each do |method|
      define_method method do |uri, params = {}|
        uri = build_uri(uri) unless uri.start_with?('https://')

        http_client.send(method, uri, params, access_token)
      end
    end

    private

    ServiceUserToken = Data.define(:token, :expires) do
      def expired?
        Time.now.to_i >= expires
      end
    end

    def access_token
      raise ClientSecretError if client_id.blank? || client_secret.blank?

      if @service_user_token.nil? || @service_user_token.expired?
        json = http_client.post_form(config['token_endpoint'], {
          grant_type: :client_credentials,
          client_id:,
          client_secret:
        })
        @service_user_token = ServiceUserToken.new(
          json['access_token'], json['expires_in'] + Time.now.to_i
        )
      end

      @service_user_token.token
    end

    def build_uri(endpoint)
      "https://#{host}/admin/realms/#{realm}/#{endpoint}"
    end

  end
end
