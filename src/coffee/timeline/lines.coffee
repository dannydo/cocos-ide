window.ci?={}

class Lines
  @_lines = []
  @_initialized = false
  @_initialize:({@parent, @layer})->
    @_initialize = true
    @_addLines()
    @_addingDoodle()

  @_addLines: ()->
    start = @_lines.length
    end = Math.floor @parent.draw.width / @parent.size.x
    if end > start 
      for x in [start...end] 
        paramaters =
          start:
            x: @parent.size.x * (x + 1)
            y: @parent.size.y + 1
          end: 
            x: @parent.size.x * (x + 1) 
            y: @parent.ocanvas.height * 5
          origin: @parent.zeroOrigin
          stroke: "1px #444"

        if x % 5 == 0
          paramaters.stroke = "1px #fff"
          text = @parent.ocanvas.display.text
            x: @parent.size.x * (x + 1)
            y: @parent.size.y - @parent.size.x
            origin: { x: "center", y: "center" },
            font: "bold #{@parent.size.x}px sans-serif",
            text: x,
            fill: "#fff"
          @layer.addChild text

        line = @parent.ocanvas.display.line paramaters
        @_lines.push line
        @layer.addChild line  

  @_addingDoodle:()->
    line = @parent.ocanvas.display.line
      start: { x: @parent.size.x , y: @parent.size.y}
      end: { x: @parent.size.x * 1000, y: @parent.size.y}
      stroke: "1px #fff"
      origin: { x: 0, y: 0 },
    @layer.addChild line

window.ci.Lines = Lines