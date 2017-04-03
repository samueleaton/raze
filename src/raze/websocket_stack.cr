class Raze::WebSocketStack
  getter middlewares
  getter block

  def initialize(handlers : Array(Raze::WebSocketHandler), &block : HTTP::WebSocket, HTTP::Server::Context -> Void)
    @middlewares = handlers
    @block = block
  end

  def initialize(*handlers, &block : HTTP::WebSocket, HTTP::Server::Context -> Void)
    @middlewares = [] of Raze::WebSocketHandler
    handlers.each { |mw| @middlewares << mw }
    @block = block
  end

  def initialize(*handlers)
    @middlewares = [] of Raze::WebSocketHandler
    handlers.each { |mw| @middlewares << mw }
    @block = nil
  end

  def initialize(handlers : Array(Raze::WebSocketHandler))
    @middlewares = handlers
    @block = nil
  end

  def initialize(&block : HTTP::WebSocket, HTTP::Server::Context -> Void)
    @middlewares = [] of Raze::WebSocketHandler
    @block = block
  end

  def concat(stack : Raze::WebSocketStack)
    @middlewares.concat stack.middlewares
    @block = stack.block
  end

  def block?
    true unless @block.nil?
  end

  # def initialize(middlewares : Array(Raze::WebSocketHandler))
  #   @middlewares = middlewares
  #   @block = nil
  # end

  def run(ws : HTTP::WebSocket, ctx : HTTP::Server::Context)
    self.next(0, ws, ctx)
  end

  def next(index, ws : HTTP::WebSocket, ctx : HTTP::Server::Context)
    if mw = @middlewares[index]?
      mw.call ctx, ->{ self.next(index + 1, ws, ctx) }
    elsif block = @block
      block.call(ws, ctx)
    end
  end
end
