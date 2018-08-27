require "radix"

class Raze::Radix(T)
  def initialize
    @tree = ::Radix::Tree(T).new
    @cached_results = {} of String => ::Radix::Result(T)
  end

  def add(path, payload)
    @tree.add path, payload
  end

  def find(path)
    # if the route already has a cached result, use it
    if cached = @cached_results[path]?
      return cached
    end

    result = @tree.find(path)

    # If the route has an associated stack and there are no dynamic params, cache it.
    # This doesn't cache the HTTP response or anything like that, it just caches
    # the associated block with the route path so it doesn't have to parse the
    # path again
    @cached_results[path] = result if result.found? && result.params.empty?

    result
  end
end
