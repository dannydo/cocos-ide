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
          @setPosition(col, row)

  setPosition: (col, row, ignore = false)->
    if @col != col or @row != row
      @col = col
      @row = row
      @frameIndicator.x = @parent.size.x * (col + 1)
      @frameIndicator.redraw()
      if not ignore
        @layer.trigger "hover-frame-selected", @

  _moveFrameIndicator: (event, ignore = false)=>
    if @_enableFrameMove
      x = Math.round ((event.x - @parent.draw.x) / @parent.size.x - 1)
      y = Math.floor ((event.y - @parent.draw.y) / @parent.size.y - 1)
      @setPosition x, y, ignore

ci.HoverIndicator = HoverIndicator