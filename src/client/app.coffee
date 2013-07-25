requirejs.config
  baseUrl: "/src/client"
  paths:
    jquery: "../../bower_components/jquery/jquery"
    socketio: "../../bower_components/socket.io-client/dist/socket.io"

requirejs ["jquery", "socketio"], ($, io) ->
  socket = io.connect()
  socket.on "mousemove", (data) ->
    $("body").append("<div class=\"point\" style=\"left: #{data.x}px; top: #{data.y}px;\"></div>")
  $(window).mousemove (event) ->
    socket.emit("mousemove", { x: event.clientX, y: event.clientY })
