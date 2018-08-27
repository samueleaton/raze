require "http"
require "json"
require "uri"
require "radix"

require "./raze/*"

module Raze
  def self.run(port = Raze.config.port)
    config = Raze.config
    config.global_handlers << Raze::ExceptionHandler::INSTANCE
    config.global_handlers << Raze::WebSocketServerHandler::INSTANCE
    config.global_handlers << Raze::ServerHandler::INSTANCE

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

    server = HTTP::Server.new(config.global_handlers)

    puts "\nraze listening at #{config.host}:#{config.port.to_s}" if config.logging
    server.listen(config.host, config.port, config.reuse_port)
  end
end
