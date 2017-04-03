
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

  def self.ws(path, &block : HTTP::WebSocket, HTTP::Server::Context -> Void)
    puts "check 1: #{path}"
    raise "websocket path \"#{path}\" must start with a \"/\"" unless path.starts_with? "/"
    stack = Raze::WebSocketStack.new(&block)
    Raze::WebSocketServerHandler::INSTANCE.add_stack path, stack
  end

  def self.ws(path, middlewares : Array(Raze::WebSocketHandler))
    puts "check 2: #{path}"
    raise "websocket path \"#{path}\" must start with a \"/\"" unless path.starts_with? "/"
    stack = Raze::WebSocketStack.new(middlewares)
    Raze::WebSocketServerHandler::INSTANCE.add_stack path, stack
  end

  def self.ws(path, middlewares : Array(Raze::WebSocketHandler), &block : HTTP::WebSocket, HTTP::Server::Context -> Void)
    puts "check 3: #{path}"
    raise "websocket path \"#{path}\" must start with a \"/\"" unless path.starts_with? "/"
    stack = Raze::WebSocketStack.new(middlewares, &block)
    Raze::WebSocketServerHandler::INSTANCE.add_stack path, stack
  end

  def self.ws(path, *middlewares)
    puts "check 4: #{path}"
    raise "websocket path \"#{path}\" must start with a \"/\"" unless path.starts_with? "/"
    stack = Raze::WebSocketStack.new(*middlewares)
    Raze::WebSocketServerHandler::INSTANCE.add_stack path, stack
  end

  def self.ws(path, *middlewares, &block : HTTP::WebSocket, HTTP::Server::Context -> Void)
    puts "check 5: #{path}"
    raise "websocket path \"#{path}\" must start with a \"/\"" unless path.starts_with? "/"
    stack = Raze::WebSocketStack.new(*middlewares, &block)
    Raze::WebSocketServerHandler::INSTANCE.add_stack path, stack
  end


  def self.error(status_code, &block : HTTP::Server::Context, Exception -> _)
    Raze.config.error_handlers[status_code] = ->(context : HTTP::Server::Context, error : Exception) { block.call(context, error).to_s }
  end
end
