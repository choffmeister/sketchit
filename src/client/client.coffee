requirejs.config
  baseUrl: "/src/client"
  paths:
    jquery: "../../bower_components/jquery/jquery"
    socketio: "../../bower_components/socket.io-client/dist/socket.io"
    underscore: "../../bower_components/underscore/underscore"
    d3: "../../bower_components/d3/d3"
    guid: "./GUID"
    geometry: "./Geometry"
  shim:
    underscore:
      exports: "_"
    d3:
      exports: "d3"

requirejs ["jquery", "socketio", "guid", "d3", "geometry"], ($, io, guid, d3, geo) ->
  svg = d3.select("body").append("svg:svg")
  canvas = svg.append("svg:g")

  paths = {}
  currentPath = null
  currentPathId = null
  currentPathElement = null

  socket = io.connect()
  socket.on "path", (data) ->
    if paths[data.id]?
      paths[data.id].path = geo.Path.deserialize(data.path)
      paths[data.id].element.attr("d", paths[data.id].path.toSvgPathString())
    else
      newPath = geo.Path.deserialize(data.path)
      newElement = canvas.append("svg:path")
        .attr("fill", "none")
        .attr("stroke", "#000000")
        .attr("stroke-width", 2)
        .attr("d", newPath.toSvgPathString())
      paths[data.id] =
        path: newPath
        element: newElement

  # disable right click
  $(window).contextmenu (event) ->
    event.preventDefault()

  onResize = () ->
    width = $(window).width()
    height = $(window).height()
    svg
      .attr("width", width)
      .attr("height", height)

  $(window).resize (event) -> onResize()
  onResize()

  $(window).mousedown (event) ->
    if not currentPath?
      currentPath = new geo.Path(new geo.Vector(event.clientX, event.clientY))
      currentPathId = guid.create()
      currentPathElement = canvas.append("svg:path")
        .attr("fill", "none")
        .attr("stroke", "#000000")
        .attr("stroke-width", 2)
        .attr("d", currentPath.toSvgPathString())
      paths[currentPathId] =
        path: currentPath
        element: currentPathElement

      socket.emit "path", {
        id: currentPathId,
        path: geo.Path.serialize(currentPath)
      }

  $(window).mouseup (event) ->
    if currentPath?
      currentPath.lineTo(new geo.Vector(event.clientX, event.clientY))
      currentPathElement.attr("d", currentPath.toSvgPathString())

      socket.emit "path", {
        id: currentPathId,
        path: geo.Path.serialize(currentPath)
      }

      currentPath = null
      currentPathId = null
      currentPathElement = null

  $(window).mousemove (event) ->
    if currentPath?
      currentPath.lineTo(new geo.Vector(event.clientX, event.clientY))
      currentPathElement.attr("d", currentPath.toSvgPathString())

      socket.emit "path", {
        id: currentPathId,
        path: geo.Path.serialize(currentPath)
      }
