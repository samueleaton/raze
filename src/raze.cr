require "http"
require "json"
require "uri"
require "tempfile"
require "radix"

require "./raze/*"

module Raze
  def self.run(port = Raze.config.port)
    config = Raze.config
    config.global_handlers << Raze::ExceptionHandler::INSTANCE
    Raze::StaticFileHandler::INSTANCE.public_dir = config.static_dir
    Raze.config.dynamic_static_paths << "/" unless config.static_indexing
    config.global_handlers << Raze::StaticFileHandler::INSTANCE
    config.global_handlers << Raze::WebSocketServerHandler::INSTANCE
    config.global_handlers << Raze::ServerHandler::INSTANCE
    config.setup

    unless Raze.config.error_handlers.has_key?(404)
      error 404 do |ctx|
        unless ctx.response.headers.has_key?("Content-Type")
          ctx.response.content_type = "text/html"
        end
        ctx.response.status_code = 404
        "Not Found"
      end
    end

    unless Raze.config.error_handlers.has_key?(500)
      error 500 do |ctx, ex|
        unless ctx.response.headers.has_key?("Content-Type")
          ctx.response.content_type = "text/html"
        end
        ctx.response.status_code = 500
        Raze.config.env == "development" ? ex.message : "An error ocurred"
      end
    end

    server = HTTP::Server.new(config.host, config.port, config.global_handlers)

    # tls/ssl if a key and a cert are added to config
    if config.tls_key && config.tls_cert
      tls_context = OpenSSL::SSL::Context::Server.new
      tls_context.private_key = config.tls_key.as(String)
      tls_context.certificate_chain = config.tls_cert.as(String)
      server.tls = tls_context
    end

    puts "\nlistening at localhost:" + config.port.to_s if config.logging
    server.listen
  end
end


# class HTTP::Server::Context
#   macro finished
#     getter body : HTTP::Params | Nil
#   end

#   def parse_urlencoded_body
#     params = request.body
#     if params
#       @body = HTTP::Params.parse(params.gets_to_end)
#     else
#       @body = HTTP::Params.parse("")
#     end
#   end
# end

# class BodyParser < Raze::Handler
#   def call(ctx, done)
#     return unless content_type = ctx.request.headers["Content-Type"]?
#     ctx.parse_urlencoded_body if content_type.starts_with?("application/x-www-form-urlencoded")
#     done.call
#   end
# end

# post "/*", BodyParser.new



class HTTP::Server::Response
  def headers=(new_headers : HTTP::Headers)
    new_headers.each do |k, v|
      puts "setting header key (#{k}) to value (#{v})"
      @headers[k] = v
    end
  end
end

get "/yee" do |ctx|
  res_headers = yee_res_headers
  puts "yee_res_headers.class: #{yee_res_headers.class}"
  puts "ctx.response.class: #{ctx.response.class}"
  if res_headers.is_a?(HTTP::Headers)
    puts "chk 1"
    ctx.response.headers = res_headers
  else
    puts "chk 2"
    ctx.response.headers["X-Yee"] = "Yee"
    yee_res_headers = ctx.response.headers
    ctx.halt_plain "yeezy"
  end
  puts "x-yee: #{ctx.response.headers["X-Yee"]?}"
end

# post "/yee"  do |ctx|
#   body = ctx.request.body.not_nil!.gets_to_end
#   json = JSON.parse(body)
#   json["name"].as_s
# end

# post "/my-route" do |ctx|
#   body = ctx.request.body.not_nil!.gets_to_end
#   json = JSON.parse(body)
#   json["name"].as_s
# end

# post "/yee/boi/yee"  do |ctx|
#   puts "yee/boi/yee ctx.body: #{ctx.body}"
#   body = ctx.body
#   if body
#     puts "yee/boi/yee ctx.body['param1']: #{body["param1"]}"
#   end
#   "yee/boi/yee"
# end

# if port = ARGV[0]?
#   Raze.config.port = port.to_i
# else
#   raise "No port given"
# end
Raze.config.port = 7897
Raze.run
