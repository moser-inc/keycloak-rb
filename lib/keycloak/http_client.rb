module Keycloak
  class HttpClient

    def get(uri, params = {}, access_token = nil)
      uri = URI.parse(uri)
      uri.query = URI.encode_www_form(params) if params.any?

      request = Net::HTTP::Get.new(uri.request_uri)
      request['Accept'] = 'application/json'
      request['Authorization'] = access_token if access_token

      response = build_http(uri).request(request)
      handle_response(response)
    end

    def post(uri, body = {}, access_token = nil)
      uri = URI.parse(uri)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.body = body.to_json
      request['Content-Type'] = 'application/json'
      request['Accept'] = 'application/json'
      request['Authorization'] = access_token if access_token

      response = build_http(uri).request(request)
      handle_response(response)
    end

    def post_form(uri, params, access_token = nil)
      uri = URI.parse(uri)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data(params)
      request['Content-Type'] = 'application/x-www-form-urlencoded; charset=utf-8'
      request['Accept'] = 'application/json'
      request['Authorization'] = access_token if access_token

      response = build_http(uri).request(request)
      handle_response(response)
    end

    private

    def build_http(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if uri.host == 'host.docker.internal'
      http
    end

    def handle_response(response)
      raise HttpResponseError, response.message unless response.is_a? Net::HTTPOK

      JSON.parse(response.body)
    end

  end
end
