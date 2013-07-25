define ["underscore"], (_) ->
  class Vector
    constructor: (x, y) ->
      @x = x
      @y = y

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

    quadraticBezierTo: (controlPoint, endPoint) =>
      @segments.push ["Q", controlPoint, endPoint]

    cubicBezierCurveTo: (controlPoint1, controlPoint2, endPoint) =>
      @segments.push ["C", controlPoint1, controlPoint2, endPoint]

    toSvgPathString: () =>
      result = ""
      for segment in @segments
        result += "#{segment[0]}"
        for point in segment[1..]
          result += "#{point.x} #{point.y} "
      return result

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
