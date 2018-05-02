module Twitter
  module REST
    class Request
      def perform
        @uri.query_values = @options
        response = http_client.headers(@headers).public_send(@request_method, @uri.to_s)
        response_body = response.body.empty? ? '' : symbolize_keys!(response.parse)
        response_headers = response.headers
        fail_or_return_response_body(response.code, response_body, response_headers)
      end
    end
  end
end
