define [], () ->
  class Vector2
    constructor: (x, y) ->
      @x = if x? then x else 0.0
      @y = if y? then y else 0.0

    length: () =>
      return Math.sqrt(@x * @x + @y * @y)

    normalize: () =>
      length = @length()
      return new Vector2(@x / length, @y / length)

    add: (v2) =>
      return new Vector2(@x + v2.x, @y + v2.y)

    subtract: (v2) =>
      return new Vector2(@x - v2.x, @y - v2.y)

    multiply: (v2) =>
      return @x * v2.x + @y * v2.y

    orth: () =>
      return new Vector2(@y, -@x).normalize()
