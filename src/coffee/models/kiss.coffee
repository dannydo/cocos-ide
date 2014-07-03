kiss.event = 
  channels : {}
  previous : {}

  on : ({channel, method, priority, ready})->
    if not channel?
      throw "_.on require name parameters"

    if not @channels[channel]?
      @channels[channel] = []
    if method not in @channels[channel]
      @channels[channel].push method

    if ready? and @previous[channel]?
      try
        method parameter
      catch exception
        console.log "kiss.event.on: #{channel}", exceptions

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
      @previous[channel] = parameter

      for method in @channels[channel]
        try
          method parameter
        catch exception
          exceptions.push exception

      if exceptions.length != 0
        console.log "kiss.event.emit", channel, parameter
        console.log "kiss.event.emit exceptions", exceptions

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
              x: kiss.event.mouse.up.clientX - kiss.event.mouse.down.clientX
              y: kiss.event.mouse.up.clientY - kiss.event.mouse.down.clientY
        delete kiss.event.mouse

    $(document).on "mousemove", (e)->
      if kiss.event.mouse?
        kiss.event.mouse.move = e
        kiss.event.emit 
          channel: "mouseDrag"
          parameter: 
            event: e
            delta:
              x: kiss.event.mouse.move.clientX - kiss.event.mouse.down.clientX
              y: kiss.event.mouse.move.clientY - kiss.event.mouse.down.clientY

        kiss.event.emit 
          channel: "moveDragOver"
          parameter: 
            event: e
            element: e.toElement
