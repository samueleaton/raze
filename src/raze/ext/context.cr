class HTTP::Server
  class Context
    getter params = {} of String => Nil | String | Int32 | Int64 | Float64 | Bool

    macro finished
      getter state = Raze::State.new
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
      self.response.headers["Content-Type"]?
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

    def halt(payload = "", status = 200)
      self.response.status_code = status
      self.response.print payload
      self.response.close
    end

    def halt_json(payload = "", status = 200)
      self.response.content_type = "application/json"
      halt payload, status
    end

    def halt_html(payload = "", status = 200)
      self.response.content_type = "text/html"
      halt payload, status
    end

    def halt_plain(payload = "", status = 200)
      self.response.content_type = "text/plain"
      halt payload, status
    end

    def redirect(url, status_code = 302)
      @response.headers.add "Location", url
      @response.status_code = status_code
    end
  end
end
