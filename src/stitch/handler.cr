module Stitch
  class Handler
    def call(context, stack)
      stack.next
    end
  end
end
