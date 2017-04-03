class Raze::Stack
  getter middlewares
  getter block

  def initialize(handlers : Array(Raze::Handler), &block : HTTP::Server::Context -> (String|Nil))
    @middlewares = handlers
    @block = block
  end

  def initialize(*handlers, &block : HTTP::Server::Context -> (String|Nil))
    @middlewares = [] of Raze::Handler
    handlers.each { |mw| @middlewares << mw }
    @block = block
  end

  def initialize(*handlers)
    @middlewares = [] of Raze::Handler
    handlers.each { |mw| @middlewares << mw }
    @block = nil
  end

  def initialize(handlers : Array(Raze::Handler))
    @middlewares = handlers
    @block = nil
  end

  def initialize(&block : HTTP::Server::Context -> (String|Nil))
    @middlewares = [] of Raze::Handler
    @block = block
  end

  def concat(stack : Raze::Stack)
    @middlewares.concat stack.middlewares
    @block = stack.block
  end

  def block?
    true unless @block.nil?
  end

  # def initialize(middlewares : Array(Raze::Handler))
  #   @middlewares = middlewares
  #   @block = nil
  # end

  def run(context : HTTP::Server::Context)
    self.next(0, context)
  end

  def next(index, context : HTTP::Server::Context)
    if mw = @middlewares[index]?
      mw.call context, ->{ self.next(index + 1, context) }
    elsif block = @block
      block.call(context)
    end
  end
end
