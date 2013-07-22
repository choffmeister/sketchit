define ["Vector2"], (Vector2) ->
  douglasPeucker = (points, epsilon) ->
    if points.length <= 2 then return points

    dmax = 0.0
    index = 0

    p1 = points[0]
    pn = points[points.length - 1]
    normal = pn.subtract(p1).orth()

    for p, i in points[1..-2]
      d = Math.abs(p.subtract(p1).multiply(normal))

      if d > dmax
        dmax = d
        index = i+1

    if dmax >= epsilon
      left = douglasPeucker(points[0..index], epsilon)
      right = douglasPeucker(points[index..], epsilon)

      return left[..-2].concat(right)
    else
      return [p1, pn]