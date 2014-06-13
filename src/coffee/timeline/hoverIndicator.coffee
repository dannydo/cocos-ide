window.ci?= {}

class HoverIndicator
  constructor:({@parent, @layer})->
    @_enableFrameMove = false
    @col = 0

    @hoverIndicator = @parent.ocanvas.display.line
      start: { x: @parent.size.x , y: @parent.size.y}
      end: { x: @parent.size.x , y: @parent.size.y * 100}
      stroke: "1px #f0f"
      origin: @parent.zeroOrigin,
    @layer.addChild @hoverIndicator

    @frameIndicator = @parent.ocanvas.display.line
      start: { x: @parent.size.x , y: @parent.size.y}
      end: { x: @parent.size.x , y: @parent.size.y * 100}
      stroke: "#{@parent.size.x}px rgba(255,0,255,0.3)"
      origin: { x: "center", y: 0 },
    @layer.addChild @frameIndicator

    @hoverIndicatorText = @parent.ocanvas.display.text
      x: @parent.size.x,  
      y: @parent.size.y - @parent.size.x,
      origin: { x: "center", y: "center" },
      font: "bold #{@parent.size.x}px sans-serif",
      text: "0",
      fill: "#f0f"
    @layer.addChild @hoverIndicatorText

    @parent.draw.bind "mousemove", (event)=>
      x = Math.round ((event.x - @parent.draw.x) / @parent.size.x - 1)
      if x != @hoverIndicatorText.text
        @hoverIndicator.x = @parent.size.x * (x + 1)
        @hoverIndicatorText.x = @hoverIndicator.x
        @hoverIndicatorText.text = x
        @hoverIndicator.redraw()

    @parent.draw.bind "mousedown", (event)=>
      @_enableFrameMove = true
      @_moveFrameIndicator event
    @parent.draw.bind "mousemove", @_moveFrameIndicator

    @parent.draw.bind "mouseup", (event)=>
      @_enableFrameMove = false
      @_moveFrameIndicator event

    @parent._knobLayer.bind "knob-selected", (event)=>
      if event.originalEvent.selected.length 
        {col, row} = event.originalEvent.selected[event.originalEvent.selected.length - 1]
        if not @_enableFrameMove
          @_enableFrameMove = true
          @_moveFrameIndicator({x:@parent.size.x * (col + 1) , y: @parent.size.y * (row+1)})
          @_enableFrameMove = false
        



  _moveFrameIndicator: (event, ignore = false)=>
    if @_enableFrameMove
      x = Math.round ((event.x - @parent.draw.x) / @parent.size.x - 1)
      y = Math.floor ((event.y - @parent.draw.y) / @parent.size.y - 1)
  
      if @col != x or @row != y
        @col = x
        @row = y
        console.log "ROPW", @row
        if not ignore
          @layer.trigger "hover-frame-selected", @

      x = @parent.size.x * (x + 1)
      if @frameIndicator.x != x
        @frameIndicator.x = x
        @frameIndicator.redraw()

ci.HoverIndicator = HoverIndicator