class Raze::Config
  INSTANCE = self.new
  property host = "0.0.0.0"
  property port = 7777
  property env = "development"
  property static_config = {"dir_listing" => true, "gzip" => true}
  property public_dir = "./public"
  property logging = true
  property always_rescue = true
  # property error_handler = nil
  # @server = uninitialized HTTP::Server


end

module Raze
  def self.config
    Raze::Config::INSTANCE
  end
end
