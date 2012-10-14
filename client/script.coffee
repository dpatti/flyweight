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
          td.mouseover         -> draw(i, j, down == 1) if down
          td.click             -> draw(i, j)
          td.on 'contextmenu', -> draw(i, j, true)

  socket.on 'update', (pixels) ->
    for {x, y, color} in pixels
      cell_grid[x][y].set_color color

  socket.on 'clear', ->
    $('td').set_color()

  $stage.mousedown (e) -> down = (e.button ? 0) - 1
  $stage.mouseup       -> down = 0
  # No right clicks on the stage, this will bubble up from td
  $stage.on 'contextmenu', (e) -> e.preventDefault()

  $('#clear').click ->
    socket.emit 'clear'
    $(this).attr('disabled', 'disabled')
    ready = Date.now() + 1000 * 10
    timer = setInterval =>
      now = Date.now()
      if now > ready
        $(this).removeAttr('disabled')
        $(this).text('Clear board')
        clearInterval(timer)
      else
        $(this).text("Clear board (#{ Math.ceil((ready - now)/1000) }s)")
    , 1000


draw = (x, y, clear) ->
  if clear
    socket.emit 'set_color', -1, {x, y}
    cell_grid[x][y].set_color()
  else
    socket.emit 'set_color', id, {x, y}
    # Automatic response
    cell_grid[x][y].set_color self_color

$.fn.set_color = (color) ->
  if color
    [r, g, b] = color
    val = "rgb(#{[r, g, b].join ','})"
  $(this).css 'background-color', val ? ''
