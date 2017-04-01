module Stitch
  class ServerHandler
    include HTTP::Handler

    INSTANCE = new
    # property tree

    def initialize
      @tree = Radix::Tree(Stitch::Stack).new
    end

    def add_stack(method, path, stack)
      node = radix_path(method, path)
      @tree.add node, stack
    end

    def lookup_route(method, path)
      @tree.find radix_path(method, path)
    end

    # TODO: allow call with block
    # def call(context, &block)
    # end

    def call(context)
      # check if there is a stack in radix that matches path
      lookup_result = lookup_route context.request.method, context.request.path
      if lookup_result.found?
        stack = lookup_result.payload.as(Stitch::Stack)
        content = stack.run_stack context
        context.response.print content if content.is_a?(String)
      else
        # TODO: raise an exception that will be rescued and return a 404
        context.response.content_type = "text/html" unless context.response.headers.has_key?("Content-Type")
        context.response.print "Not Found"
        context.response.status_code = 404
      end
    end

    private def radix_path(method, path)
      # TODO: replace with string builder
      "/#{method.downcase}#{path}"
    end
  end
end
