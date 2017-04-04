class HTTP::Server
  class Context
    alias StoreTypes = Nil | String | Int32 | Int64 | Float64 | Bool
    alias JsonTypes = StoreTypes | Hash(String, JSON::Type) | Array(JSON::Type)

    getter params = {} of String => StoreTypes
    getter query = {} of String => StoreTypes
    getter json = {} of String => JsonTypes
    getter body = HTTP::Params.new({} of String => Array(String))
    getter locals = {} of String => StoreTypes
    
    def params=(parameters)
      parameters.each do |key, val|
        @params[key] = URI.unescape(val)
      end
    end

    def query=(raw_query_string)
      return unless raw_query_string && raw_query_string.size > 0
      query_params = Raze::Utils.parse_params(raw_query_string)
      query_params.each do |key, val|
        @query[key] = URI.unescape(val)
      end
    end

    def parse_body
      return unless content_type = request.headers["Content-Type"]?

      if content_type == "application/json"
        parse_json_body
      elsif content_type == "application/x-www-form-urlencoded"
        @body = Raze::Utils.parse_params request.body
      end
    end

    private def parse_json_body
      body = request.body.not_nil!.gets_to_end
      begin
        case json = JSON.parse(body).raw
        when Hash
          json.each do |key, value|
            @json[key.as(String)] = value.as(JsonTypes)
          end
        when Array
          @json["array"] = json
        end
      rescue ex : JSON::ParseException
        # TODO: puts in documentation about invalid json
        @json["invalid"] = ex.message
      end
    end

    def redirect(url, status_code = 302)
      @response.headers.add "Location", url
      @response.status_code = status_code
    end
  end
end
