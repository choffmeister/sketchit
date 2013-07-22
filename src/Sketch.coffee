define ["jquery", "d3", "jspdf", "Path"], ($, d3, jsPDF, Path) ->
  class Sketch
    constructor: (container) ->
      @container = $(container)
      @svg = d3.select(@container.get(0)).append("svg:svg")

      @paths = []
      @current = null

      @registerEvents()
      @onResize(null)

    registerEvents: () =>
      $(window).resize (event) => @onResize(event)
      $(window).mousedown (event) => @onMouseDown(event)
      $(window).mouseup (event) => @onMouseUp(event)
      $(window).mousemove (event) => @onMouseMove(event)

    toPDF: () =>
      doc = new jsPDF("landscape", "mm", "a4")
      doc.setLineWidth(1.0)

      for path in @paths
        for i in [0..path.points.length-2]
          p0 = path.points[i]
          p1 = path.points[i+1]
          doc.line(p0.x, p0.y, p1.x, p1.y)

      return doc

    onResize: (event) =>
      @svg
        .attr("width", @container.width())
        .attr("height", @container.height())

    onMouseDown: (event) =>
      if event.button == 0
        @current = new Path()
        @current.append(event.clientX, event.clientY)
        @paths.push(@current)

    onMouseUp: (event) =>
      if event.button == 0
        @current.simplify()
        @current.draw(@svg)
        @current = null

    onMouseMove: (event) =>
      if @current?
        @current.append(event.clientX, event.clientY)
        @current.draw(@svg)
