# A group of websockets
class Raze::WebSocketChannel
  property websockets = [] of HTTP::WebSocket
  property channel_name : String

  def initialize(@channel_name)
  end

  def add(sock)
    websockets << sock
  end
  
  def remove(sock : HTTP::WebSocket)
    websockets.reject! {|ws| ws.object_id == sock.object_id }
    Raze::WebSocketChannels::INSTANCE.channels.delete(@channel_name) if websockets.size <= 0
  end

  def remove(sock : HTTP::WebSocket, &block : Raze::WebSocketChannel -> _)
    remove sock
    block.call(self) if websockets.size > 0
  end

  def broadcast(msg)
    websockets.each do |ws|
      ws.send(msg)
    end
  end

  def size
    websockets.size
  end
end
