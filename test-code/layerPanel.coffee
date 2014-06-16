root = exports ? this

class root.LayerPanel extends root.Ui
  constructor: ()->
    @_configure()
    @_initialize()
    @_applyStyling()
    @_registerEvent()
    @_bind()
    super arguments...

  _initialize:()->
    @background       = paper.rect 0, 0, 0, 0

    @row              = paper.rect 0, 0, 0, 0
    @spot             = paper.rect 0, 0, 0, 0
    @visible          = paper.rect 0, 0, 0, 0
    @lock             = paper.path icon.lock
    @lock.attr
      fill: "black"
      stroke: "red"
      transform: "matrix(1,0,0,1,116,116)"
    window.lock = @lock

    @audio            = paper.rect 0, 0, 0, 0


  _configure:()->
    @config =
      background :
        fill : "#ddd"
      row :
        fill : "#eee"
        height: 32

  _applyStyling:()->
    @background.attr
      fill: @config.background.fill
    @row.attr
      fill: @config.row.fill

  _registerEvent:()->

  _bind:()->

  _applySizing:()->
    @background.attr
      x: @size.x
      y: @size.y
      height: @size.height
      width: @size.width

    @row.attr
      x: @size.x
      y: @size.y
      height: @config.row.height
      width: @size.width
      


new LayerPanel
  x: 100
  y: 116
  height: 400
  width: 400
  name: "layerPanel"
