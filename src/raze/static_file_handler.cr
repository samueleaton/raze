{% if !flag?(:without_zlib) %}
  require "zlib"
{% end %}

class Raze::StaticFileHandler < HTTP::StaticFileHandler
  def call(ctx)
    return call_next(ctx) if ctx.request.path.not_nil! == "/"

    unless ctx.request.method == "GET" || ctx.request.method == "HEAD"
      if @fallthrough
        call_next(ctx)
      else
        ctx.response.status_code = 405
        ctx.response.headers.add("Allow", "GET, HEAD")
      end
      return
    end

    request_path = URI.unescape(ctx.request.path.not_nil!).rstrip "/"

    file_or_dir = Raze.static_file_indexer.static_files[request_path]?
    return call_next(ctx) unless file_or_dir

    file_path = String.build do |str|
      str << Raze.config.static_dir
      str << request_path
    end

    process_request(ctx, file_or_dir, request_path, file_path)
  end

  private def process_request(ctx, file_type, request_path, file_path)
    if file_type == "dir"
      ctx.response.content_type = "text/html"
      directory_listing(ctx.response, request_path, file_path)
    elsif file_type == "file"
      return if etag(ctx, file_path)
      Raze::Helpers.send_file(ctx, file_path)
    else
      call_next(ctx)
    end
  end

  private def etag(ctx, file_path)
    etag = %{W/"#{File.lstat(file_path).mtime.epoch.to_s}"}

    headers = ctx.request.headers
    headers["ETag"] = etag
    return false if !headers["If-None-Match"]? || headers["If-None-Match"] != etag

    ctx.response.headers.delete "Content-Type"
    ctx.response.content_length = 0
    ctx.response.status_code = 304 # not modified
    return true
  end
end
