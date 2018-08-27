class Raze::Config
  INSTANCE = self.new

  property host = "0.0.0.0"
  property port = 7777
  property reuse_port = false
  property env = ENV["CRYSTAL_ENV"]? || ENV["crystal_env"]? || "development"
  property logging = true
  property global_handlers = [] of HTTP::Handler
  property error_handlers = {} of Int32 => HTTP::Server::Context, Exception -> String
end

module Raze
  def self.config
    Raze::Config::INSTANCE
  end
end
