fs      = require 'fs'
async   = require 'async'
coffee  = require 'coffee-script'
less    = require 'less'
Server  = require './server.coffee'

server = new Server(process.env.PORT || 8426)

# Static routes
cache = {}
server.app.get '/', (req, res) ->
  async.series [
    (next) ->
      return next() if cache.html
      fs.readFile 'client/app.html', (err, file) ->
        cache.html = file
        next()

    (next) ->
      res.set 'Content-Type', 'text/html'
      res.send cache.html
      next()
  ]

server.app.get '/script.js', (req, res) ->
  async.series [
    (next) ->
      return next() if cache.js
      fs.readFile 'client/script.coffee', (err, file) ->
        cache.js = coffee.compile file.toString()
        next()

    (next) ->
      res.set 'Content-Type', 'text/javascript'
      res.send cache.js
      next()
  ]

server.app.get '/style.css', (req, res) ->
  async.series [
    (next) ->
      return next() if cache.css
      fs.readFile 'client/style.less', (err, file) ->
        less.render file.toString(), (err, contents) ->
          cache.css = contents
          next()

    (next) ->
      res.set 'Content-Type', 'text/css'
      res.send cache.css
      next()
  ]
