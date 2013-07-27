define ["underscore"], (_) ->
  class Vector
    constructor: (x, y) ->
      @x = x
      @y = y

    squaredLength: () =>
      return @x * @x + @y * @y;

    length: () =>
      return Math.sqrt(@squaredLength())

    normalize: () =>
      length = @length()
      return new Vector(@x / length, @y / length)

    add: (v2) =>
      return new Vector(@x + v2.x, @y + v2.y)

    subtract: (v2) =>
      return new Vector(@x - v2.x, @y - v2.y)

    multiply: (v2) =>
      return @x * v2.x + @y * v2.y

    orth: () =>
      return new Vector(@y, -@x).normalize()

    clone: () =>
      return Vector.deserialize(Vector.serialize(this))

    @serialize: (point) ->
      return [point.x, point.y]

    @deserialize: (json) ->
      return new Vector(json[0], json[1])

  class Path
    constructor: (startPoint) ->
      @segments = []
      if startPoint? then @segments.push ["M", startPoint]

    lineTo: (endPoint) =>
      @segments.push ["L", endPoint]

    quadraticBezierCurveTo: (controlPoint, endPoint) =>
      @segments.push ["Q", controlPoint, endPoint]

    cubicBezierCurveTo: (controlPoint1, controlPoint2, endPoint) =>
      @segments.push ["C", controlPoint1, controlPoint2, endPoint]

    join: (nextPath) =>
      thisLastSegment = @segments[@segments.length - 1]
      nextFirstSegment = nextPath.segments[0]

      if nextFirstSegment[0] == "M" and nextFirstSegment[1].x == thisLastSegment[thisLastSegment.length - 1].x and nextFirstSegment[1].y == thisLastSegment[thisLastSegment.length - 1].y
        newPath = this.clone()
        newPath.segments = newPath.segments.concat(nextPath.clone().segments[1..])
        return newPath
      else
        newPath = this.clone()
        newPath.segments = newPath.segments.concat(nextPath.clone().segments[..])
        return newPath

    toSvgPathString: () =>
      result = ""
      for segment in @segments
        result += "#{segment[0]}"
        for point in segment[1..]
          result += "#{point.x} #{point.y} "
      return result

    clone: () =>
      return Path.deserialize(Path.serialize(this))

    @serialize: (path) ->
      json = _.map path.segments, (segment) ->
        points = _.map segment[1..], (point) -> Vector.serialize(point)
        return [segment[0]].concat(points)
      return json

    @deserialize: (json) ->
      path = new Path()
      path.segments = _.map json, (segment) ->
        points = _.map segment[1..], (point) -> Vector.deserialize(point)
        return [segment[0]].concat(points)
      return path

  return {
    Vector: Vector
    Path: Path
  }
