require "../handler"
require "uri"

# A middleware for proxying the request to another endpoint
class Raze::Proxy < Raze::Handler
  @target_hosts = [] of String
  @target_path = ""
  @next_target_host_index = 0
  @headers : Hash(String, String) | Nil
  @timeout : Int32 | Nil

  def initialize(host : String, path = "", @lchop_proxy_path = "", @ignore_proxy_path = false, @headers = nil, @timeout = nil)
    @target_hosts << host
    @target_path = path
    if timeout = @timeout
      timeout = nil
    end
    validate_props
  end

  def initialize(host : Array(String), path = "", @lchop_proxy_path = "", @ignore_proxy_path = false, @headers = nil, @timeout = nil)
    raise "Proxy hosts array cannot be empty" if host.empty?
    @target_hosts = host
    @target_path = path
    if timeout = @timeout
      timeout = nil
    end
    validate_props
  end

  def call(ctx, done)
    # get the request information
    req_method = ctx.request.method
    req_headers = ctx.request.headers
    req_body = ctx.request.body
    req_path = ctx.request.path

    # set any headers that need to be set
    if headers = @headers
      headers.each do |k, v|
        req_headers[k] = v
      end
    end

    # TODO: if or when Crystal exposes the remote ip address, set the
    # "X-Forwarded-For" header.
    # https://github.com/crystal-lang/crystal/issues/453

    client = HTTP::Client.new(URI.parse get_host)

    # set timeout if specified
    if timeout = @timeout
      client.connect_timeout = timeout.seconds
      client.read_timeout = timeout.seconds
    end

    begin
      response = client.exec(
        req_method, generate_path(req_path), req_headers, req_body
      )
      response.headers.each do |k, v|
        ctx.response.headers[k] = v
      end
      ctx.response.status_code = response.status_code
      ctx.response << response.body
      ctx.response.close
    rescue IO::Timeout
      ctx.response.status_code = 408
    end
  end

  # gets host amd updates the round-robin index
  private def get_host
    host = @target_hosts[@next_target_host_index]

    if @target_hosts[@next_target_host_index + 1]?
      @next_target_host_index = @next_target_host_index + 1
    else
      @next_target_host_index = 0
    end

    host
  end

  private def generate_path(req_path)
    path = String.build do |io|
      io << @target_path
      unless @ignore_proxy_path
        io << req_path.lchop @lchop_proxy_path
      end
    end
    path.empty? ? "/" : path
  end

  private def validate_props
    @target_hosts.each do |host|
      uri = URI.parse host
      path = uri.path
      raise "Proxy hosts cannot contain a hash (##{uri.fragment})" if uri.fragment
      raise "Proxy hosts cannot contain a query string (?#{uri.query})" if uri.query
      if path && !path.empty?
        raise "Proxy hosts cannot contain a path (#{uri.path}). Use the 'path' argument when initializing Raze::Proxy instead"
      end
    end
  end
end
