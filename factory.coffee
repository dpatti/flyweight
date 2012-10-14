_ = require 'underscore'
Color = require './color.coffee'

class ColorFactory
  constructor: ->
    @cache = []

  blank: new Color(0, 0, 100)

  get: (color) ->
    if color in @cache
      return color

    @cache.push color
    return color

  random: ->
    return @get new Color(Math.random()*360, Math.random()*50 + 50, Math.random()*50 + 50)

module.exports = ColorFactory
