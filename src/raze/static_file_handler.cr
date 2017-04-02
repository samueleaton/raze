{% if !flag?(:without_zlib) %}
  require "zlib"
{% end %}

class Raze::StaticFileHandler < HTTP::StaticFileHandler
  def call(context)
    return call_next(context) if context.request.path.not_nil! == "/"

    unless context.request.method == "GET" || context.request.method == "HEAD"
      if @fallthrough
        call_next(context)
      else
        context.response.status_code = 405
        context.response.headers.add("Allow", "GET, HEAD")
      end
      return
    end

    request_path = URI.unescape(context.request.path.not_nil!).rstrip "/"
    file_path = String.build do |str|
      str << Raze.config.public_dir
      str << request_path
    end

    file_or_dir = Raze.static_file_indexer.static_files[request_path]?
    return call_next(context) unless file_or_dir

    if file_or_dir == "dir"
      context.response.content_type = "text/html"
      directory_listing(context.response, request_path, file_path)
    elsif file_or_dir == "file"
      return if etag(context, file_path)
      Raze.send_file(context, file_path)
    else
      call_next(context)
    end
  end

  private def etag(context, file_path)
    etag = %{W/"#{File.lstat(file_path).mtime.epoch.to_s}"}

    headers = context.request.headers
    headers["ETag"] = etag
    return false if !headers["If-None-Match"]? || headers["If-None-Match"] != etag

    context.response.headers.delete "Content-Type"
    context.response.content_length = 0
    context.response.status_code = 304 # not modified
    return true
  end
end
