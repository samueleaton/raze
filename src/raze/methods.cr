
module Raze
  HTTP_METHODS_OPTIONS   = %w(all get post put patch delete options)
  {% for method in HTTP_METHODS_OPTIONS %}

    # ```
    # Raze.get "/hello" do |context|
    #   "Hello, world!"
    # end
    # ```

    def self.{{method.id}}(path, &block : HTTP::Server::Context -> (String|Nil))
      stack = Raze::Stack.new(&block)
      Raze::ServerHandler::INSTANCE.add_stack {{method}}.upcase, path, stack
    end

    # ```
    # Raze.get "/hello", [CustomHandler.new, OtherHandler.new]
    # ```

    def self.{{method.id}}(path, middlewares : Array(Raze::Handler))
      stack = Raze::Stack.new(middlewares)
      Raze::ServerHandler::INSTANCE.add_stack {{method}}.upcase, path, stack
    end

    # ```
    # Raze.get "/hello", [CustomHandler.new, OtherHandler.new] do |context|
    #   "Hello, world!"
    # end
    # ```

    def self.{{method.id}}(path, middlewares : Array(Raze::Handler), &block : HTTP::Server::Context -> (String|Nil))
      stack = Raze::Stack.new(middlewares, &block)
      Raze::ServerHandler::INSTANCE.add_stack {{method}}.upcase, path, stack
    end

    # ```
    # Raze.get "/hello", CustomHandler.new, OtherHandler.new
    # ```

    def self.{{method.id}}(path, *middlewares)
      stack = Raze::Stack.new(*middlewares)
      Raze::ServerHandler::INSTANCE.add_stack {{method}}.upcase, path, stack
    end

    # ```
    # Raze.get "/hello", CustomHandler.new, OtherHandler.new do |context|
    #   "Hello, world!"
    # end
    # ```

    def self.{{method.id}}(path, *middlewares, &block : HTTP::Server::Context -> (String|Nil))
      stack = Raze::Stack.new(*middlewares, &block)
      Raze::ServerHandler::INSTANCE.add_stack {{method}}.upcase, path, stack
    end
  {% end %}

  def self.error(status_code, &block : HTTP::Server::Context, Exception -> _)
    Raze.config.error_handlers[status_code] = ->(context : HTTP::Server::Context, error : Exception) { block.call(context, error).to_s }
  end
end
