root = exports ? this

class root.TimeLinePanel extends root.Ui
  constructor: ()->
    @_configure()
    @_initialize()
    @_applyStyling()
    @_registerEvent()
    @_bind()
    super arguments...

  _initialize:()->
    @background       = paper.rect 0, 0, 0, 0

  _configure:()->
    @config =
      background :
        fill : "#ddd"

  _applyStyling:()->
    @background.attr
      fill: @config.background.fill

  _registerEvent:()->

  _bind:()->

  _applySizing:()->
    @background.attr
      x: @size.x
      y: @size.y
      height: @size.height
      width: @size.width    


new TimeLinePanel
  x: 500
  y: 116
  height: 400
  width: 600
  name: "timeLinePanel"
