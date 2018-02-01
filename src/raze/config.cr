class Raze::Config
  INSTANCE = self.new

  property host = "0.0.0.0"
  property port = 7777
  property reuse_port = false
  property env = ENV["CRYSTAL_ENV"]? || ENV["crystal_env"]? || "development"
  property static_dir_listing = false
  property compress = true
  property static_indexing = true
  property static_dir = "./static"
  property dynamic_static_paths = [] of String
  property logging = true
  property global_handlers = [] of HTTP::Handler
  property error_handlers = {} of Int32 => HTTP::Server::Context, Exception -> String
  property tls_key : String | Nil = nil
  property tls_cert : String | Nil = nil

  def setup
    Raze.static_file_indexer.index_files if static_indexing
  end
end

module Raze
  def self.config
    Raze::Config::INSTANCE
  end
end
