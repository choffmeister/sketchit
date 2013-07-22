define ["d3", "Vector2", "douglaspeucker"], (d3, Vector2, douglaspeucker) ->
  class Path
    @lineTemplate = d3.svg.line()
      .x((d) -> d.x)
      .y((d) -> d.y)
      .interpolate("linear")

    constructor: () ->
      @points = []

    draw: (g) ->
      if not @path? then @path = g.append("svg:path")

      @path
        .attr("d", Path.lineTemplate(@points))
        .attr("class", "path")

    simplify: () =>
      countBefore = @points.length
      @points = douglaspeucker(@points, 1.0)
      countAfter = @points.length
      console.log "Douglas/Peucker: #{countBefore} -> #{countAfter}"

    append: (x, y) =>
      @points.push(new Vector2(x, y))

    clear: () =>
      @points = []
      