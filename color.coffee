class Color
  constructor: (h, s, v) ->
    @h = h
    @s = s / 100
    @v = v / 100

  to_rgb: ->
    chroma = @v * @s
    hprime = @h / 60
    partial = chroma * (1 - Math.abs(hprime % 2 - 1))
    rgb = if 0 <= hprime < 1
      [chroma, partial, 0]
    else if 1 <= hprime < 2
      [partial, chroma, 0]
    else if 2 <= hprime < 3
      [0, chroma, partial]
    else if 3 <= hprime < 4
      [0, partial, chroma]
    else if 4 <= hprime < 5
      [partial, 0, chroma]
    else if 5 <= hprime < 6
      [chroma, 0, partial]

    return rgb.map (i) => Math.round((i + @v - chroma) * 255)

module.exports = Color
