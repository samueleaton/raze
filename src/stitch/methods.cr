module Stitch
  def self.get(path, middlewares : Array(Stitch::Handler), &block : HTTP::Server::Context -> String)
    # build stack
    stack = Stitch::Stack.new(middlewares, &block)

    # add stack to radix
    Stitch::ServerHandler::INSTANCE.add_stack "GET", path, stack
  end

  def self.get(path, &block : HTTP::Server::Context -> String)
    # build stack
    stack = Stitch::Stack.new(&block)

    # add stack to radix
    Stitch::ServerHandler::INSTANCE.add_stack "GET", path, stack
  end

  def self.get(path, middlewares : Array(Stitch::Handler))
    # build stack
    stack = Stitch::Stack.new(middlewares)

    # add stack to radix
    Stitch::ServerHandler::INSTANCE.add_stack "GET", path, stack
  end
end
