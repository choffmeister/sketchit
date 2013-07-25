path = require "path"
http = require "http"
express = require "express"
socketio = require "socket.io"

app = express()
app.configure () ->
  app.use express.cookieParser()
  app.use express.session({ secret: "secret", key: "express.sid" })
  app.use "/bower_components", express.static(path.join(__dirname, "bower_components"))
  app.use "/node_modules", express.static(path.join(__dirname, "node_modules"))
  app.use "/src", express.static(path.join(__dirname, "src"))
  app.use express.static(path.join(__dirname, "public"))

server = http.createServer(app)

socket = socketio.listen(server)
socket.sockets.on "connection", (socket) ->
  socket.on "path", (data) ->
    socket.broadcast.emit "path", data

module.exports = server
module.exports.use = () -> app.use.apply(app, arguments)
