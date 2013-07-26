###
Provides algorithms for fitting Bezier curves to a set of digitized points.

Title: An Algorithm for Automatically Fitting Digitized Curves
Author: Philip J. Schneider.
Book: "Graphics Gems", Academic Press, 1990
Url: http://ftp.arl.mil/pub/Gems/original/FitDigitizedCurves.c
###
define ["geometry"], (geo) ->
  B0 = (t) ->
    tmp = 1.0 - t
    return tmp * tmp * tmp

  B1 = (t) ->
    tmp = 1.0 - t
    return 3 * t * tmp * tmp

  B2 = (t) ->
    tmp = 1.0 -t
    return 3 * t * t * tmp

  B3 = (t) ->
    return t * t * t

  douglasPeucker = (points, epsilon) ->
    if points.length <= 2 then return points

    dmax = 0.0
    index = 0

    p1 = points[0]
    pn = points[points.length - 1]
    normal = pn.subtract(p1).orth()

    for p, i in points[1..-2]
      d = Math.abs(p.subtract(p1).dot(normal))

      if d > dmax
        dmax = d
        index = i+1

    if dmax >= epsilon
      left = douglasPeucker(points[0..index], epsilon)
      right = douglasPeucker(points[index..], epsilon)

      return left[..-2].concat(right)
    else
      return [p1, pn]

  parameterizePolylineLength = (points, i1, i2) ->
    u = [0.0]

    for i in [i1+1..i2]
      u[i - i1] = u[i - i1 - 1] + points[i].subtract(points[i - 1]).length()
    for i in [i1+1..i2]
      u[i - i1] = u[i - i1] / u[i2 - i1]

    return u

  evaluateCubic = (bezierCurve, t) ->
    s0 = bezierCurve[0].scale(B0(t))
    s1 = bezierCurve[1].scale(B1(t))
    s2 = bezierCurve[2].scale(B2(t))
    s3 = bezierCurve[3].scale(B3(t))
    return s0.add(s1.add(s2.add(s3)))

  computeMaxError = (points, i1, i2, bezierCurve, uprime) ->
    maxDist = null
    maxDistIndex = null

    for i in [i1+1..i2-1]
      p = evaluateCubic(bezierCurve, uprime[i - i1])
      v = p.subtract(points[i])
      dist = v.squaredLength()

      if maxDist == null or dist >= maxDist
        maxDist = dist
        maxDistIndex = i

    return {
      dist: maxDist
      index: maxDistIndex
    }

  leastSquaresCubicBezier = (points, i1, i2, uprime, hat1, hat2) ->
    numPoints = i2 - i1 + 1
    bezierCurve = [null, null, null, null]

    A = []
    for i in [0..numPoints-1]
      A[i] = [
        hat1.scale(B1(uprime[i])),
        hat2.scale(B2(uprime[i]))
      ]

    C = [[0.0, 0.0], [0.0, 0.0]]
    X = [0.0, 0.0]

    for i in [0..numPoints-1]
      C[0][0] += A[i][0].dot(A[i][0])
      C[0][1] += A[i][0].dot(A[i][1])
      C[1][0] += A[i][1].dot(A[i][0])
      C[1][1] += A[i][1].dot(A[i][1])

      tmp = points[i1 + i].subtract(points[i1].scale(B0(uprime[i])).add(points[i1].scale(B1(uprime[i])).add(points[i2].scale(B2(uprime[i])).add(points[i2].scale(B3(uprime[i]))))))

      X[0] += A[i][0].dot(tmp)
      X[1] += A[i][1].dot(tmp)

    det_C0_C1 = C[0][0] * C[1][1] - C[1][0] * C[0][1]
    det_C0_X  = C[0][0] * X[1]    - C[0][1] * X[0]
    det_X_C1  = X[0]    * C[1][1] - X[1]    * C[0][1]

    if det_C0_C1 == 0.0 then det_C0_C1 = C[0][0] * C[1][1] * 10e-12;
    alpha_l = det_X_C1 / det_C0_C1
    alpha_r = det_C0_X / det_C0_C1

    if alpha_l < 1.0e-6 || alpha_r < 1.0e-6
      dist = points[i2].subtract(points[i1]).length()
      bezierCurve[0] = points[i1].clone()
      bezierCurve[3] = points[i2].clone()
      bezierCurve[1] = bezierCurve[0].add(hat1.scale(dist))
      bezierCurve[2] = bezierCurve[3].add(hat2.scale(dist))
    else
      bezierCurve[0] = points[i1].clone()
      bezierCurve[3] = points[i2].clone()
      bezierCurve[1] = bezierCurve[0].add(hat1.scale(alpha_l))
      bezierCurve[2] = bezierCurve[3].add(hat2.scale(alpha_r))

    return bezierCurve

  fitCubic = (points, i1, i2, hat1, hat2, error) ->
    if i2 - i1 + 1 == 2
      dist = points[i1].subtract(points[i2]).length()

      return [
        points[i1].clone(),
        points[i1].add(hat1.scale(dist)),
        points[i2].add(hat2.scale(dist)),
        points[i2].clone()
      ]
    else
      uprime = parameterizePolylineLength(points, i1, i2)
      bezierCurve = leastSquaresCubicBezier(points, i1, i2, uprime, hat1, hat2)
      maxError = computeMaxError(points, i1, i2, bezierCurve, uprime)

      if maxError.dist <= error
        return bezierCurve
      else
        v1 = points[maxError.index - 1].subtract(points[maxError.index])
        v2 = points[maxError.index].subtract(points[maxError.index + 1])
        hatCenter = v1.add(v2).normalize()

        bezierCurve1 = fitCubic(points, i1, maxError.index, hat1, hatCenter, error)
        bezierCurve2 = fitCubic(points, maxError.index, i2, hatCenter.scale(-1.0), hat2, error)

        return bezierCurve1.concat(bezierCurve2[1..])

  curveFitting = (points, error) ->
    points = douglasPeucker(points, error)

    hat1 = points[1].subtract(points[0]).normalize()
    hat2 = points[points.length - 2].subtract(points[points.length - 1]).normalize()

    return fitCubic(points, 0, points.length - 1, hat1, hat2, error)

