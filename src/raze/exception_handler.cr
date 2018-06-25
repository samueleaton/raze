class Raze::ExceptionHandler
  include HTTP::Handler
  INSTANCE = new

  def call(context)
    call_next(context)
  rescue ex : Raze::Exceptions::RouteNotFound
    call_exception_with_status_code(context, ex, 404)
  rescue ex : Raze::Exceptions::CustomException
    call_exception_with_status_code(context, ex, context.response.status_code)
  rescue ex : Exception
    # log("Exception: #{ex.inspect_with_backtrace}")
    call_exception_with_status_code(context, ex, 500)
  end

  private def call_exception_with_status_code(context, exception, status_code)
    if handler_status_code = Raze.config.error_handlers[status_code]?
      context.response.content_type = "text/html" unless context.response.headers["Content-Type"]?
      context.response.print handler_status_code.call(context, exception)
      context.response.status_code = status_code
      context
    end
  end
end
