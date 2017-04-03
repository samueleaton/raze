class Raze::WebSocketServerHandler < HTTP::WebSocketHandler
  INSTANCE = new do |sock, ctx|
    lookup_result = Raze::WebSocketServerHandler::INSTANCE.lookup_route(ctx.request.path)
    ctx.params = lookup_result.params
    ctx.query = ctx.request.query

    stack = lookup_result.payload.as(Raze::WebSocketStack)
    content = stack.run(sock, ctx)
  end

  def initialize(&@proc : HTTP::WebSocket, HTTP::Server::Context -> Void)
    @tree = Radix::Tree(Raze::WebSocketStack).new
  end

  def add_stack(path, stack)
    node = radix_path(path)
    lookup_result = lookup_route(path)
    if lookup_result.found?
      # check if stack has an ending block
      existing_stack = lookup_result.payload.as(Raze::WebSocketStack)
      raise "There is already an existing block for WS #{path}" if existing_stack.block?
      existing_stack.concat stack
    else
      @tree.add node, stack
    end
  end

  def lookup_route(path)
    @tree.find radix_path(path)
  end

  private def radix_path(path)
    String.build do |str|
      str << "/ws"
      str << path
    end
  end

  def call(ctx)
    super
  ensure
    if Raze.config.error_handlers.has_key?(ctx.response.status_code)
      raise Raze::Exceptions::CustomException.new(ctx)
    end
  end

  # def initialize(@path : String, &@proc : HTTP::WebSocket, HTTP::Server::Context -> Void)
  #   Raze.config.global_handlers << self
  # end

  # def call(context)
  #   return call_next(context) unless context.request.path.not_nil! == @path
  #   super
  # end
end
