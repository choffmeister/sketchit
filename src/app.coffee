requirejs.config
  baseUrl: "/src"
  paths:
    jquery: "../components/jquery/jquery"
    underscore: "../components/underscore/underscore"
    d3: "../components/d3/d3"

  shim:
    jqueryui:
      deps: ["jquery"]
    underscore:
      exports: "_"
    d3:
      exports: "d3"

resize = (svg) ->
  svg
    .attr("width", $(window).width())
    .attr("height", $(window).height())

draw = (svg, current) ->
  lineTemplate = d3.svg.line()
    .x((d) -> d.x)
    .y((d) -> d.y)
    .interpolate("linear")

  current.element
    .attr("d", lineTemplate(current.points))
    .attr("class", "path")

requirejs ["jquery", "d3"], ($, d3) ->
  svg = d3.select("#canvas").append("svg:svg")
  resize(svg)

  current = null

  $(window).resize (event) ->
    resize(svg)

  $(window).mousedown (event) ->
    if event.button == 0
      current =
        element: svg.append("path")
        points: []

  $(window).mouseup (event) ->
    if event.button == 0
      current = null

  $(window).mousemove (event) ->
    if current?
      current.points.push {
        x: event.clientX
        y: event.clientY
      }
      draw(svg, current)
