class HTTP::Server
  class Context
    TYPE_MAP = [Nil, String, Int32, Int64, Float64, Bool]

    macro finished
      alias StoreTypes = Union({{ *TYPE_MAP }})
      alias JsonTypes = StoreTypes | Hash(String, JSON::Type) | Array(JSON::Type)
      getter state = {} of String => StoreTypes
      getter params = {} of String => StoreTypes
      # getter query = {} of String => StoreTypes
      getter json = {} of String => JsonTypes
      getter body = HTTP::Params.new({} of String => Array(String))
    end

    def query
      self.request.query_params
    end

    def params=(parameters)
      parameters.each do |key, val|
        @params[key] = URI.unescape(val)
      end
    end

    def content_type
      self.response.content_type
    end

    def content_type=(ct)
      self.response.content_type = ct
    end

    def status_code
      self.response.status_code
    end

    def status_code=(status)
      self.response.status_code = status
    end

    # def query=(raw_query_string)
    #   return unless raw_query_string && raw_query_string.size > 0
    #   query_params = Raze::Utils.parse_params(raw_query_string)
    #   query_params.each do |key, val|
    #     @query[key] = URI.unescape(val)
    #   end
    # end

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
