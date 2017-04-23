class Raze::Config
  INSTANCE = self.new

  property host = "0.0.0.0"
  property port = 7777
  property env = "development"
  property static_config = {"dir_listing" => false, "gzip" => true}
  property static_dir = "./static"
  property logging = true
  property always_rescue = true
  property global_handlers = [] of HTTP::Handler
  property error_handlers = {} of Int32 => HTTP::Server::Context, Exception -> String

  # property error_handler = nil
  # @server = uninitialized HTTP::Server

  def setup
    Raze.static_file_indexer.index_files
  end
end

module Raze
  def self.config
    Raze::Config::INSTANCE
  end
end
