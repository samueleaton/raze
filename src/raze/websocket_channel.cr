# A group of websockets
class Raze::WebSocketChannel
  alias MsgTypes = Nil | String | Int32 | Int64 | Float64 | Bool
  property websockets = [] of HTTP::WebSocket
  property channel_name : String

  def initialize(@channel_name)
  end

  def add(sock)
    websockets << sock unless websockets.find { |ws| ws.object_id == sock.object_id }
  end

  def remove(sock : HTTP::WebSocket)
    removed_socks = websockets.reject! { |ws| ws.object_id == sock.object_id }
    Raze::WebSocketChannels::INSTANCE.channels.delete(@channel_name) if websockets.size <= 0
  end

  def remove(sock : HTTP::WebSocket, &block : Raze::WebSocketChannel -> _)
    remove sock
    block.call(self) if websockets.size > 0
  end

  def broadcast(msg : String)
    websockets.each do |ws|
      ws.send(msg)
    end
  end

  def broadcast(msg)
    msg_hash = cast_hash msg
    websockets.each do |ws|
      ws.send(msg_hash.to_json)
    end
  end


  def size
    websockets.size
  end

  private def cast_hash(hash)
    msg_hash = {} of String => MsgTypes
    hash.each do |key, val|
      msg_hash[key] = val
    end
    msg_hash
  end
end
