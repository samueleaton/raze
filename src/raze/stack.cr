class Raze::Stack
  alias Context_types = HTTP::Server::Context | String | Int32 | Int64 | Bool | Nil
  getter middlewares
  getter block
  # A sub tree is used in case this stack is indexed using a wildcard
  # For example, if there is one stack at the path "/hel**" and another at the
  # path "/hello", the latter would be in the subtree of the first
  property tree : Raze::Radix(Raze::Stack) | Nil = nil

  def initialize(handlers : Array(Raze::Handler), &block : HTTP::Server::Context -> Context_types)
    @middlewares = handlers
    @block = block
  end

  def initialize(handlers : Array(Raze::Handler))
    @middlewares = handlers
    @block = nil
  end

  def initialize(*handlers, &block : HTTP::Server::Context -> Context_types)
    @middlewares = [] of Raze::Handler
    @middlewares.concat handlers
    @block = block
  end

  def initialize(*handlers)
    @middlewares = [] of Raze::Handler
    @middlewares.concat handlers
    @block = nil
  end

  def initialize(&block : HTTP::Server::Context -> Context_types)
    @middlewares = [] of Raze::Handler
    @block = block
  end

  # combines stacks of with matching paths
  def concat(stack : Raze::Stack)
    @middlewares.concat stack.middlewares
    @block = stack.block
  end

  def block?
    true unless @block.nil?
  end

  def tree?
    true unless @tree.nil?
  end

  # def initialize(middlewares : Array(Raze::Handler))
  #   @middlewares = middlewares
  #   @block = nil
  # end

  def run(ctx : HTTP::Server::Context)
    self.next(0, ctx)
  end

  def next(index, ctx : HTTP::Server::Context)
    if mw = @middlewares[index]?
      mw.call ctx, ->{ self.next(index + 1, ctx) }
    elsif block = @block
      block.call(ctx)
    elsif _tree = tree
      # find and run the sub tree
      find_result = _tree.find(radix_path(ctx.request.method, ctx.request.path))
      if find_result.found?
        ctx.params = find_result.params
        find_result.payload.as(Raze::Stack).run(ctx)
      else
        raise Raze::Exceptions::RouteNotFound.new(ctx)
      end
    end
  end

  def add_sub_tree(stack, node, method, path)
    # add tree to the existing stack because there is some globbing going on
    @tree = Raze::Radix(Raze::Stack).new unless tree?
    sub_tree = @tree.as(Raze::Radix(Raze::Stack))
    # add stack to this sub tree
    sub_tree.add node, stack
    sub_tree.add(radix_path("HEAD", path), Raze::Stack.new() { |ctx| "" }) if method == "GET"
  end

  private def radix_path(method, path)
    '/' + method.downcase + path
  end
end
