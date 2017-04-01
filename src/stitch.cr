require "./stitch/*"
require "radix"

module Stitch
  def self.get(path, middlewares : Array(Stitch::Handler), &block)
    mw_caller = Stitch::Wrapper.new(path, middlewares, &block)
    mw_caller.prepare_next
  end

  class Wrapper
    @index = -1

    def initialize(path : String, middlewares : Array(Stitch::Handler), &block)
      @path = path
      @middlewares = middlewares
      @block = block
    end

    def prepare_next
      @index += 1
      run_next
    end

    def run_next
      next_mw = @middlewares[@index]?
      if next_mw
        @middlewares[@index].call @path, @index, ->prepare_next
      else
        @block.call
      end
    end
  end

  class Handler
    def call(path, index, prep_next)
      puts "this is handler: " + index.to_s
      prep_next.call
    end
  end
end


# tree = Radix::Tree(String).new

# tree.add "/", "root"
# tree.add "/user", "user"
# tree.add "/api/v1", "apiV1"

# result = tree.find "/user"

# if result.found?
#   puts "found: " + result.payload
# else
#   puts "not found"
# end




Stitch.get "/user", [Stitch::Handler.new, Stitch::Handler.new, Stitch::Handler.new] do
  puts "end of the road"
  "yee"
end
