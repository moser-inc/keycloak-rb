module Keycloak
  class HttpClient

    def get(uri, params = {}, access_token = nil)
      uri = URI.parse(uri)
      uri.query = URI.encode_www_form(params) if params.any?

      request(:get, uri, access_token)
    end

    def post(uri, body = {}, access_token = nil)
      uri = URI.parse(uri)

      request(:post, uri, access_token) do |request|
        request.body = body.to_json
        request['Content-Type'] = 'application/json'
      end
    end

    def put(uri, body = {}, access_token = nil)
      uri = URI.parse(uri)

      request(:put, uri, access_token) do |request|
        request.body = body.to_json
        request['Content-Type'] = 'application/json'
      end
    end

    def post_form(uri, params, access_token = nil)
      uri = URI.parse(uri)

      request(:post, uri, access_token) do |request|
        request.set_form_data(params)
        request['Content-Type'] = 'application/x-www-form-urlencoded; charset=utf-8'
      end
    end

    private

    def request(verb, uri, access_token)
      request = Object.const_get("Net::HTTP::#{verb.capitalize}").new(uri.request_uri)
      request['Accept'] = 'application/json'
      request['Authorization'] = "Bearer #{access_token}" if access_token

      yield(request) if block_given?

      response = build_http(uri).request(request)
      handle_response(response)
    end

    def build_http(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if uri.host == 'host.docker.internal'
      http
    end

    def handle_response(response)
      case response
      when Net::HTTPOK
        JSON.parse(response.body)
      when Net::HTTPNoContent
        nil
      else
        raise HttpResponseError, response.message
      end
    end

  end
end
