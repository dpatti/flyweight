$stage = $('#stage')
socket = io.connect('/')

id = null
cell_grid = {}
down = false
self_color = null
socket.on 'connect', ->
  console.log "Connected"
  socket.on 'state', (state) ->
    { id, size, grid, color: self_color } = state

    # Generate grid
    for i in [0...size]
      tr = $('<tr>').appendTo $stage
      cell_grid[i] = {}
      for j in [0...size]
        do (i, j) ->
          td = $('<td>').appendTo tr
          cell_grid[i][j] = td
          # Set initial color by state
          if grid[i]?[j]
            td.set_color grid[i][j]
          # Set click handler
          td.mouseover -> draw(i, j) if down
          td.click ->     draw(i, j)


  socket.on 'update', (pixels) ->
    for {x, y, color} in pixels
      cell_grid[x][y].set_color color

  $stage.mousedown -> down = true
  $stage.mouseup ->   down = false

draw = (x, y) ->
  socket.emit 'set_color', id, {x, y}
  # Automatic response
  cell_grid[x][y].set_color self_color

$.fn.set_color = ([r, g, b]) ->
  $(this).css 'background-color', "rgb(#{[r, g, b].join ','})"
