require "http"
require "json"
require "uri"
require "tempfile"
require "radix"

require "./raze/*"

module Raze
  GLOBAL_HANDLERS = [] of HTTP::Handler

  def self.add_global_handler(handler : HTTP::Handler)
    GLOBAL_HANDLERS << handler
  end

  def self.zip_types(path) # https://github.com/h5bp/server-configs-nginx/blob/master/nginx.conf
    [".htm", ".html", ".txt", ".css", ".js", ".svg", ".json", ".xml", ".otf", ".ttf", ".woff", ".woff2"].includes? File.extname(path)
  end

  def self.mime_type(path)
    case File.extname(path)
    when ".txt"          then "text/plain"
    when ".htm", ".html" then "text/html"
    when ".css"          then "text/css"
    when ".js"           then "application/javascript"
    when ".png"          then "image/png"
    when ".jpg", ".jpeg" then "image/jpeg"
    when ".gif"          then "image/gif"
    when ".svg"          then "image/svg+xml"
    when ".ico"          then "image/x-icon"
    when ".xml"          then "application/xml"
    when ".json"         then "application/json"
    when ".otf", ".ttf"  then "application/font-sfnt"
    when ".woff"         then "application/font-woff"
    when ".woff2"        then "font/woff2"
    else                      "application/octet-stream"
    end
  end

  def self.send_file(env, path : String, mime_type : String? = nil)
    static_config = Raze.config.static_config
    file_path = File.expand_path(path, Dir.current)
    mime_type ||= Raze.mime_type(file_path)
    env.response.content_type = mime_type
    minsize = 860 # http://webmasters.stackexchange.com/questions/31750/what-is-recommended-minimum-object-size-for-gzip-performance-benefits ??
    request_headers = env.request.headers
    filesize = File.size(file_path)
    File.open(file_path) do |file|
      if env.request.method == "GET" && env.request.headers.has_key?("Range")
        next self.multipart(file, env)
      end
      if request_headers.includes_word?("Accept-Encoding", "gzip") && static_config.is_a?(Hash) && static_config["gzip"] == true && filesize > minsize && Raze.zip_types(file_path)
        env.response.headers["Content-Encoding"] = "gzip"
        Gzip::Writer.open(env.response) do |deflate|
          IO.copy(file, deflate)
        end
      elsif request_headers.includes_word?("Accept-Encoding", "deflate") && static_config.is_a?(Hash) && static_config["gzip"]? == true && filesize > minsize && Raze.zip_types(file_path)
        env.response.headers["Content-Encoding"] = "deflate"
        Flate::Writer.new(env.response) do |deflate|
          IO.copy(file, deflate)
        end
      else
        env.response.content_length = filesize
        IO.copy(file, env.response)
      end
    end
    return
  end

  def self.multipart(file, env)
    # See http://httpwg.org/specs/rfc7233.html
    fileb = file.size

    range = env.request.headers["Range"]
    match = range.match(/bytes=(\d{1,})-(\d{0,})/)

    startb = 0
    endb = 0

    if match
      if match.size >= 2
        startb = match[1].to_i { 0 }
      end

      if match.size >= 3
        endb = match[2].to_i { 0 }
      end
    end

    if endb == 0
      endb = fileb
    end

    if startb < endb && endb <= fileb
      env.response.status_code = 206
      env.response.content_length = endb - startb
      env.response.headers["Accept-Ranges"] = "bytes"
      env.response.headers["Content-Range"] = "bytes #{startb}-#{endb - 1}/#{fileb}" # MUST

      if startb > 1024
        skipped = 0
        # file.skip only accepts values less or equal to 1024 (buffer size, undocumented)
        until skipped + 1024 > startb
          file.skip(1024)
          skipped += 1024
        end
        if skipped - startb > 0
          file.skip(skipped - startb)
        end
      else
        file.skip(startb)
      end

      IO.copy(file, env.response, endb - startb)
    else
      env.response.content_length = fileb
      env.response.status_code = 200 # Range not satisfable, see 4.4 Note
      IO.copy(file, env.response)
    end
  end

  def self.run(port = Raze.config.port)
    Raze.add_global_handler Raze::StaticFileHandler.new("./public")
    Raze.add_global_handler Raze::ServerHandler::INSTANCE

    server = HTTP::Server.new(Raze.config.host, Raze.config.port, GLOBAL_HANDLERS)
    puts "\nlistening at localhost:" + Raze.config.port.to_s
    server.listen
  end
end

# class Authenticator1 < Raze::Handler
#   def call(context, stack)
#     context.response.puts "Access Granted. (1)"
#     puts "Authenticator 1"
#     stack.call
#   end
# end

# class Authenticator2 < Raze::Handler
#   def call(context, stack)
#     context.response.puts "Access Granted. (2)"
#     puts "Authenticator 2"
#     stack.call
#   end
# end

class Logger
  include HTTP::Handler

  def call(context)
    # replace with string builder
    puts "\n#{context.request.method} #{context.request.path}"
    call_next(context)
  end
end
# Raze.add_global_handler Logger.new

# class Async < Raze::Handler
#   def call(context, stack)
#     context.response.puts "Async triggered"
#     stack.call
#     # context.response.close
#     # spawn { stack.call }
#   end
# end

# class LogHello < Raze::Handler
#   def call(context, stack)
#     puts "Logging Hello..."
#     stack.call
#   end
# end



# Raze.get "/user", [Authenticator1.new, Raze::Handler.new, Raze::Handler.new] do |context|
#   # puts "end of the road"
#   "/user"
# end

# auth1 = Authenticator1.new
# auth2 = Authenticator2.new

Raze.get "/hello" do
  "Hello, world!"
end

# Raze.get "/hello/:name" do |context|
#   puts "params: " + context.params.inspect
#   "yee boi"
# end

# Raze.get "/hello/world", [auth2, Raze::Handler.new] do |context|
#   "Hello, world!"
# end


# Raze.get "/hello", [Authenticator1.new.as(Raze::Handler), Raze::Handler.new] do |context|
#   "kewl"
# end
# Raze.all "/yee/**", LogHello.new

Raze.get "/yee/boi" do |context|
  "Yeezy"
end

# Raze.get "/yee", Async.new, LogHello.new do |context|
#   context.response.puts "yee boi"
#   res = context.response.close
#   nil
# end

# Raze.get "/sam", [auth1, Raze::Handler.new]

Raze.run
