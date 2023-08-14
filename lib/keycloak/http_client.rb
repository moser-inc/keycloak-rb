module Keycloak
  class HttpClient

    def initialize(host)
      uri = URI.parse(host)

      @http = Net::HTTP.new(uri.host, uri.port)
      @http.use_ssl = uri.scheme == 'https'
      @http.verify_mode = OpenSSL::SSL::VERIFY_NONE if host == 'host.docker.internal'
    end

    def get(uri, params = {}, access_token: nil)
      uri = URI.parse(uri)
      uri.query = URI.encode_www_form(params) if params.any?

      request(:get, uri, access_token)
    end

    def post(uri, body = {}, access_token: nil)
      uri = URI.parse(uri)

      request(:post, uri, access_token) do |request|
        request.body = body.to_json
        request['Content-Type'] = 'application/json'
      end
    end

    def put(uri, body = {}, access_token: nil)
      uri = URI.parse(uri)

      request(:put, uri, access_token) do |request|
        request.body = body.to_json
        request['Content-Type'] = 'application/json'
      end
    end

    def post_form(uri, params, access_token: nil)
      uri = URI.parse(uri)

      request(:post, uri, access_token) do |request|
        request.set_form_data(params)
        request['Content-Type'] = 'application/x-www-form-urlencoded; charset=utf-8'
      end
    end

    private

    def request(verb, uri, access_token)
      start_time = current_time_in_ms
      request = Object.const_get("Net::HTTP::#{verb.capitalize}").new(uri.request_uri)
      request['Accept'] = 'application/json'
      request['Authorization'] = "Bearer #{access_token}" if access_token

      yield(request) if block_given?

      response = @http.request(request)
      elapsed = current_time_in_ms - start_time
      Keycloak.logger.info "HTTP #{verb.upcase} #{uri} #{response.code} (#{elapsed}ms): #{response.message}"

      handle_response(response)
    end

    def handle_response(response)
      case response
      when Net::HTTPOK
        JSON.parse(response.body)
      when Net::HTTPCreated
        response.header['location']
      when Net::HTTPNoContent
        nil
      when Net::HTTPNotFound
        raise HttpNotFoundError, response
      else
        raise HttpResponseError, response
      end
    end

    def current_time_in_ms
      DateTime.now.strftime('%Q').to_i
    end

  end
end
