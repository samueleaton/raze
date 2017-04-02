module Raze
  class Handler
    def call(context, done)
      done.call
    end
  end
end
