module Raze
  # `State` is an empty class used for carrying values across middleware
  # through a route's execution. By default it acts as a hash to store
  # common data types by a string key.
  # ```
  # ctx.state["foo"] = "bar"
  # ctx.state["foo"] # "bar"
  # ```
  # You can add custom containers for any type by using the `add_state_property` macro.
  # ```
  # Raze.add_state_property user : UserModel
  # # Later, in a middleware or route..
  # ctx.state.user # UserModel
  #```
  class State
    @values = {} of String => Nil | String | Int32 | Int64 | Float64 | Bool

    property int : Int16 | Int32 | Int64 | Nil
    property uint : UInt16 | UInt32 | UInt64  | Nil
    property string : String?
    property float : Float32 | Float64 | Nil
    property bool : Bool?

    def [](key)
      @values[key]
    end

    def []?(key)
      @values[key]?
    end

    def []=(key, value)
      @values[key] = value
    end
  end

  # Adds a custom `property` to the `State` class by reopening.
  macro add_state_property(*props)
    class ::Raze::State
      {% for prop in props %}
        property {{prop}}
      {% end %}
    end
  end
end
