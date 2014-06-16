if global?
  require './../../console/boot.coffee'
  kiss = global.kiss
else
  root = window
  kiss = root.kiss ? {}

if kiss.event? and __filename? and __filename == process.argv[1]
  console.log "test code for kiss.event goes here"
  return

kiss.event = 
  channels : {}
  on : ({channel, method, priority})->
    if not channel?
      throw "_.on require name parameters"

    if not @channels[channel]?
      @channels[channel] = []
    if method not in @channels[channel]
        @channels[channel].push method

  off : ({channel, method})->
    if not channel?
      throw "_.off require name parameters"

    if @channels[channel]?
      _.pull @channels[channel], method

  emit : ({channel, parameter})->
    if not channel?
      throw "_.emit require name parameters"

    if @channels[channel]?
      exceptions  = []
      for method in @channels[channel]
        try
          method parameter
        catch exception
          exceptions.push exception

      if exceptions.length != 0
        console.log "exceptions", exceptions

  once : ({channel, parameter, priority})->


if $?
  $ ->
    $(document).on "mousedown", (e)->
      kiss.event.mouse =
        down: e

      kiss.event.emit 
        channel: "mouseDragStart"
        parameter: 
          event: e
          delta:
            x: 0
            y: 0

    $(document).on "mouseup", (e)->
      if kiss.event.mouse?
        kiss.event.mouse.up = e
        kiss.event.emit 
          channel: "mouseDragStop"
          parameter: 
            event: e
            delta:
              x: kiss.event.mouse.up.x - kiss.event.mouse.down.x
              y: kiss.event.mouse.up.y - kiss.event.mouse.down.y
        delete kiss.event.mouse

    $(document).on "mousemove", (e)->
      if kiss.event.mouse?
        kiss.event.mouse.move = e
        kiss.event.emit 
          channel: "mouseDrag"
          parameter: 
            event: e
            delta:
              x: kiss.event.mouse.move.x - kiss.event.mouse.down.x
              y: kiss.event.mouse.move.y - kiss.event.mouse.down.y

        kiss.event.emit 
          channel: "moveDragOver"
          parameter: 
            event: e
            element: e.toElement
