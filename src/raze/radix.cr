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

    # if the route has an associated stack and there are no dynamic params, cache it
    @cached_results[path] = result if result.found? && result.params.empty?
    result
  end
end
