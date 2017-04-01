module Stitch
  class Stack
    # start at -1 because it will increment before each, so the first will be 0
    @index = -1

    def initialize(middlewares : Array(Stitch::Handler), &block : HTTP::Server::Context -> String)
      @middlewares = middlewares
      @block = block
    end

    def initialize(&block : HTTP::Server::Context -> String)
      @middlewares = nil
      @block = block
    end

    # def initialize(middlewares : Array(Stitch::Handler))
    #   @middlewares = middlewares
    #   @block = nil
    # end

    def run_stack(context : HTTP::Server::Context)
      @context = context
      self.next
    end

    def next
      middlewares = @middlewares
      context = @context.as(HTTP::Server::Context)
      if middlewares
        if mw = middlewares[@index += 1]?
          mw.call context, self
        elsif block = @block
          block.call(context)
        end
      elsif block = @block
        block.call(context)
      end
    end
  end
end
