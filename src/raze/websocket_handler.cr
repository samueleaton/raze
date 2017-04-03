class Raze::WebSocketHandler < HTTP::WebSocketHandler
  def initialize(@path : String, &@proc : HTTP::WebSocket, HTTP::Server::Context -> Void)
    Raze.config.global_handlers << self
  end

  def call(context)
    return call_next(context) unless context.request.path.not_nil! == @path
    super
  end
end
