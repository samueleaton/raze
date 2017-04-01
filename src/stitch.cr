require "http"
require "./stitch/*"
require "radix"

module Stitch
  def self.get(path, middlewares : Array(Stitch::Handler), &block : HTTP::Server::Context -> String)
    # build stack
    stack = Stitch::Stack.new(middlewares, &block)

    # add stack to radix
    Stitch::ServerHandler::INSTANCE.add_stack "GET", path, stack
  end

  def self.get(path, &block : HTTP::Server::Context -> String)
    # build stack
    stack = Stitch::Stack.new(&block)

    # add stack to radix
    Stitch::ServerHandler::INSTANCE.add_stack "GET", path, stack
  end

  def self.run(port = 7777)
    handler = Stitch::ServerHandler::INSTANCE
    server = HTTP::Server.new("127.0.0.1", port, [handler])
    # puts "\nlistening at localhost:" + port.to_s
    server.listen
  end

end

# class Authenticator < Stitch::Handler
#   def call(context, stack)
#     context.response.puts "Access Granted."
#     stack.next
#   end
# end

# Stitch.get "/user", [Authenticator.new, Stitch::Handler.new, Stitch::Handler.new] do |context|
#   # puts "end of the road"
#   "/user"
# end

Stitch.get "/hello" do |context|
  "Hello, world!"
end

Stitch.run
