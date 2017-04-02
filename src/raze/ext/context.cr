class HTTP::Server
  class Context
    alias StoreTypes = Nil | String | Int32 | Int64 | Float64 | Bool
    @params = {} of String => StoreTypes

    def params
      @params
    end

    def params=(parameters)
      parameters.each do |key, val|
        @params[key] = URI.unescape(val)
      end
    end

    def redirect(url, status_code = 302)
      @response.headers.add "Location", url
      @response.status_code = status_code
    end

    # def get(name)
    #   @params[name]
    # end

    # def set(name, value)
    #   @params[name] = value
    # end
  end
end
