require "http"
require "json"
require "uri"
require "tempfile"
require "radix"

require "./raze/*"

module Raze
  def self.run(port = Raze.config.port)
    config = Raze.config
    config.global_handlers << Raze::StaticFileHandler.new(Raze.config.static_dir)
    config.global_handlers << Raze::ExceptionHandler::INSTANCE
    config.global_handlers << Raze::ServerHandler::INSTANCE

    unless Raze.config.error_handlers.has_key?(404)
      Raze.error 404 do |ctx|
        unless ctx.response.headers.has_key?("Content-Type")
          ctx.response.content_type = "text/html"
        end
        ctx.response.status_code = 404
        "Not Found"
      end
    end

    unless Raze.config.error_handlers.has_key?(500)
      Raze.error 500 do |ctx, ex|
        unless ctx.response.headers.has_key?("Content-Type")
          ctx.response.content_type = "text/html"
        end
        ctx.response.status_code = 500
        Raze.config.env == "development" ? ex.message : "An error ocurred"
      end
    end

    server = HTTP::Server.new(config.host, config.port, config.global_handlers)
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
# Raze.config.global_handlers << Logger.new

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

Raze.get "/hello/:name" do |context|
  puts "raw query: #{context.request.query}"
  puts "query params: #{context.query}"
  "yee, #{context.params["bad_name"]}"
end

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

Raze.post "/yee/boi" do |context|
  puts "headers: #{context.request.headers}"
  puts "raw body: #{context.request.body}"
  puts "json body: #{context.json}"
  puts "param body: #{context.body}"
  puts "name: #{context.body["name"]}"
  puts "age: #{context.body["age"]}"
  puts "email: #{context.body["email"]}"
  "Yeezy"
end

# Raze.get "/yee", Async.new, LogHello.new do |context|
#   context.response.puts "yee boi"
#   res = context.response.close
#   nil
# end

# Raze.get "/sam", [auth1, Raze::Handler.new]

Raze.run
