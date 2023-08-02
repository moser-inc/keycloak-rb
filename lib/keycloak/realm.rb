require 'net/http'
require 'jwt'
require_relative 'error'
require_relative 'http_client'
require_relative 'service_user'

module Keycloak
  class Realm
    include ServiceUser

    attr_reader :host, :realm, :client_id, :client_secret, :http_client

    def initialize(host: Keycloak.host,
      realm: Keycloak.realm,
      client: Keycloak.client,
      secret: Keycloak.secret)

      @host = host
      @realm = realm
      @client_id = client
      @client_secret = secret

      @http_client = HttpClient.new(@host)
      @service_user_token = nil
    end

    def config
      @config ||= http_client.get(
        "#{host}/realms/#{realm}/.well-known/openid-configuration",
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
      define_method method do |endpoint, *args, **kwargs|
        kwargs[:access_token] = service_user_token
        http_client.send(method, "#{host}/admin/realms/#{realm}/#{endpoint}", *args, **kwargs)
      end
    end
  end
end
