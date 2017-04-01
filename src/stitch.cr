require "http"
require "./stitch/*"
require "radix"

module Stitch
  GLOBAL_HANDLERS = [] of HTTP::Handler

  def self.add_global_handler(handler : HTTP::Handler)
    GLOBAL_HANDLERS << handler
  end

  def self.run(port = 7777)
    handler = Stitch::ServerHandler::INSTANCE
    GLOBAL_HANDLERS << handler
    server = HTTP::Server.new("127.0.0.1", port, GLOBAL_HANDLERS)
    puts "\nlistening at localhost:" + port.to_s
    server.listen
  end
end

class Authenticator < Stitch::Handler
  def call(context, stack)
    context.response.puts "Access Granted."
    stack.next
  end
end

class Logger
  include HTTP::Handler

  def call(context)
    puts context.request.method + " " + context.request.path
    call_next(context)
  end
end

Stitch.add_global_handler Logger.new
# Stitch.get "/user", [Authenticator.new, Stitch::Handler.new, Stitch::Handler.new] do |context|
#   # puts "end of the road"
#   "/user"
# end

Stitch.get "/hello", [Authenticator.new.as(Stitch::Handler), Stitch::Handler.new] do |context|
  "Hello, world!"
end

Stitch.get "/sam", [Authenticator.new.as(Stitch::Handler), Stitch::Handler.new]

Stitch.run
