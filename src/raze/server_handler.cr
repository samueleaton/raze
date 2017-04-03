require "./ext/context"

module Raze
  class ServerHandler
    include HTTP::Handler

    INSTANCE = new
    # property tree

    def initialize
      @tree = Radix::Tree(Raze::Stack).new
    end

    def add_stack(method, path, stack)
      return add_all_stack(path, stack) if method == "ALL"

      node = radix_path(method, path)
      lookup_result = lookup_route(method, path)
      if lookup_result.found?
        # check if stack has an ending block
        existing_stack = lookup_result.payload.as(Raze::Stack)
        raise "There is already an existing block for #{method.upcase} #{path}." if existing_stack.block?
        existing_stack.concat stack
      else
        @tree.add node, stack
        @tree.add(radix_path("HEAD", path), Raze::Stack.new() {|ctx| ""}) if method == "GET"
      end
    end

    # TODO: this needs to also lookup ALL paths
    def lookup_route(method, path)
      @tree.find radix_path(method, path)
    end

    # TODO: allow passing a block to call
    # def call(context, &block)
    # end

    def call(ctx)
      # check if there is a stack in radix that matches path
      lookup_result = lookup_route ctx.request.method, ctx.request.path
      if lookup_result.found?
        ctx.params = lookup_result.params
        ctx.query = ctx.request.query

        ctx.parse_body if ctx.request.body

        stack = lookup_result.payload.as(Raze::Stack)
        content = stack.run ctx
        if content.is_a?(String) && !ctx.response.closed?
          ctx.response.print content
        end
      else
        # TODO: raise an exception that will be rescued and return a 404
        unless ctx.response.headers.has_key?("Content-Type")
          ctx.response.content_type = "text/html"
        end
        ctx.response.print "Not Found"
        ctx.response.status_code = 404
      end
    end

    private def add_all_stack(path, stack)
      if stack.block?
        # if method is ALL, the stack can have a block if there is not already a
        # more specific method with a block
        Raze::HTTP_METHODS_OPTIONS.each do |method_option|
          method_option_match = lookup_route(method_option, path)
          if method_option_match.found?
            existing_method_stack = method_option_match.payload.as(Raze::Stack)
            if existing_method_stack.block?
              raise "There is already an existing block for #{method_option.upcase} #{path}. A block for ALL is not allowed."
            end
          end
        end
      end
      Raze::HTTP_METHODS_OPTIONS.each do |method_option|
        add_stack(method_option, path, stack)
      end
    end

    private def radix_path(method, path)
      String.build do |str|
        str << "/"
        str << method.downcase
        str << path
      end
    end
  end
end
