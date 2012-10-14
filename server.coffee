_            = require 'underscore'
io           = require 'socket.io'
express      = require 'express'
ColorFactory = require './factory.coffee'

class Server
  constructor: (port) ->
    # Initialize server and clients
    @app = express()
    @clients = []
    server = require('http').createServer(@app)
    server.listen port, -> console.log "Listening on #{ port }"

    # Initialize factory
    @factory = new ColorFactory()

    # Initialize grid of pixels
    @grid = {}

    # Set up sockets
    io = io.listen(server)
    io.sockets.on 'connection', (socket) =>
      id = @add_client(socket)
      socket.emit 'state', _.extend @fetch_state(), { id, color: @clients[id].color.to_rgb() }
      socket.on 'set_color', @set_color
      socket.on 'clear', ->
        @grid = {}
        io.sockets.emit 'clear'
      socket.on 'disconnect', ->

    # Make sure we don't update too frequently
    @update = _.throttle @update, 250
    @queue = []

  # Registration of a route to a method
  register: (method, route, fx) ->
    @app[method.toLowerCase()](route, fx)

  # New client looking for all information
  fetch_state: =>
    # Map colors to rgb
    color_grid = {}
    for i of @grid
      color_grid[i] = {}
      for j, c of @grid[i]
        color_grid[i][j] = c.to_rgb()
    grid: color_grid

  # Called on connect
  add_client: (conn) ->
    id = @clients.length
    @clients.push
      color: @factory.random()
      conn: conn
    return id

  # Gets called via socket
  set_color: (id, {x, y}) =>
    # Only respond to valid coordinates
    if x > 0 and  y > 0
      color = @clients[id]?.color ? @factory.blank
      @grid[x] ?= {}
      # Skip if we're not changing it
      return if @grid[x][y] == color
      @grid[x][y] = color
      # Add to the queue and schedule an update
      @queue.push {x, y, color: color.to_rgb()}
      @update()

  update: ->
    # Send queued updates to each client
    io.sockets.emit 'update', @queue
    # Empty the queue
    @queue.splice 0

module.exports = Server
