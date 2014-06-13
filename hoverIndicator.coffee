window.ci?= {}

class HoverIndicator
  constructor:({@parent, @layer})->

    @hoverIndicator = @parent.ocanvas.display.line
      start: { x: @parent.size.x , y: @parent.size.y}
      end: { x: @parent.size.x , y: @parent.size.y * 100}
      stroke: "1px #f0f"
      origin: @parent.zeroOrigin,
    @layer.addChild @hoverIndicator

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

ci.HoverIndicator = HoverIndicator