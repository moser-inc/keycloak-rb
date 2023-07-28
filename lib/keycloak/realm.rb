require 'net/http'
require 'jwt'
require_relative 'error'
require_relative 'http_client'

module Keycloak
  class Realm
    attr_reader :host, :realm, :client, :secret, :http_client

    def initialize(host: Keycloak.host,
      realm: Keycloak.realm,
      client: Keycloak.client,
      secret: Keycloak.secret)
      @host = host
      @realm = realm
      @client = client
      @secret = secret
      @http_client = HttpClient.new
    end

    def config
      @config ||= http_client.get(
        "https://#{host}/realms/#{realm}/.well-known/openid-configuration"
      )
      @config
    end

    def jwks_certificates
      @jwks_certificates ||= http_client.get(config['jwks_uri'])
      @jwks_certificates
    end

    def decode(token)
      decoded = JWT.decode(token, nil, true, { algorithms: ['RS256'], jwks: lambda do |options|
        @cached_keys = nil if options[:invalidate]
        @cached_keys ||= { keys: jwks_certificates['keys'] }
      end })

      decoded&.first
    end

    [:get, :post, :put].each do |method|
      define_method method do |uri, params = {}|
        uri = build_uri(uri) unless uri.start_with?('https://')

        http_client.send(method, uri, params, access_token)
      end
    end

    private

    def access_token
      raise ClientSecretError if client.blank? || secret.blank?

      @access_token ||= http_client.post_form(config['token_endpoint'], {
        grant_type: 'client_credentials',
        client_id: client,
        client_secret: secret
      })['access_token']

      @access_token
    end

    def build_uri(endpoint)
      "https://#{host}/admin/realms/#{realm}/#{endpoint}"
    end

  end
end
