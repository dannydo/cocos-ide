root = exports ? this

class root.TimeLine
  constructor:({@x, @y, @width, @height})->
    @timeScale         = 1
    @panelRatio        = 0.5
    @timePanelMinWidth = 200
    @infoPanelMinWidth = 200
    @rows              = []
    @initialize()

  initialize: ()->

    paper.setStart()
    @scrubHandle  = paper.rect @x, @y,  8, @height
    @timePanel    = paper.rect @x, @y,  0, @height
    @infoPanel    = paper.rect @x, @y,  0, @height
    @bottomSet    = paper.setFinish()
    
    @bottomSet.attr 
      stroke : ""
    
    @scrubHandle.insertAfter @infoPanel

    @infoPanel.attr    fill: "#fdd"
    @scrubHandle.attr  fill: "#fff"
    @timePanel.attr    fill: "#ddf"


    @scrubHandle.drag [
      (x, y, dx, dy, e)=>
        @resizePanel 
          panelRatio: (@scrubHandle.x + x) / (@width)
    ,
      (x, y, e)->
        @attr 
          fill   : "#aaa"
        {@x} = @attrs
    ,
      (e)->
        @attr 
          fill   : "#fff"
    ]...


  resize: ({width, height}={})->
    @width = width ? @width
    @height = height ? @height

    @_checkPanelRatio()
    @_applyResizePanel()

    mediator.emit "TimeLine.resize", @width, @height

  _applyResizePanel:()->
    @scrubHandle.attr
      x: @x + @width * @panelRatio - @scrubHandle.attrs.width

    @infoPanel.attr
      x: @x
      width: @width * @panelRatio - @scrubHandle.attrs.width

    @timePanel.attr
      x: @x + @width * @panelRatio 
      width: @width * (1 - @panelRatio) - @scrubHandle.attrs.width

    @bottomSet.attr
      y: @y
      height: @height

  _checkPanelRatio:()->
    if @timePanelMinWidth > 
        @width * (1 - @panelRatio) - @scrubHandle.attrs.width
      @panelRatio = 1 - @timePanelMinWidth / @width
    else if @infoPanelMinWidth > 
        @width * @panelRatio - @scrubHandle.attrs.width
      @panelRatio = @infoPanelMinWidth / @width

  resizePanel: ({panelRatio})->
    @panelRatio = panelRatio ? @panelRatio
    @resize()
    mediator.emit "TimeLine.separator", @panelRatio

  addRow:({rowName})->
    @rows.push rowName
    mediator.emit "TimeLine.addRow", rowName

  removeRow:({rowName})->
    _.pull @rows, rowName
    mediator.emit "TimeLine.removeRow", rowName




tl = new TimeLine
  x: 10
  y: 10
  width: 800
  height: 250

tl.resizePanel({panelRatio:0.2})


window.getRect = (m)->
  [ 
    m.x(0,0), m.y(0,0) 
    m.x(200,0), m.y(200,0) 
    m.x(0,200), m.y(0,200) 
    m.x(200,200), m.y(200,200) 
  ]



$("#dragme2").on "mousedown", (e)->
  me = $(@)
  initial =
    left: parseFloat(me.css("left"))
    top: parseFloat(me.css("top"))

  me.css
    "pointer-events": "none"

  drop = $("#dropme2")

  moveDragOver = ({event, element})->
    if drop[0] == element
      drop.css
        background: "black"
    else
      drop.css
        background: "yellow"


  mouseDrag = ({event, delta})->
    me.css
      left: initial.left + delta.x
      top: initial.top + delta.y

  mouseDragStop = ({event, delta})->
    me.css
      left: initial.left + delta.x
      top: initial.top + delta.y

    me.css
      "pointer-events": ""

    kiss.event.off 
      channel: "mouseDrag"
      method: mouseDrag

    kiss.event.off 
      channel: "mouseDragStop"
      method: mouseDragStop

    kiss.event.off 
      channel: "moveDragOver"
      method: moveDragOver

  kiss.event.on 
    channel: "mouseDrag"
    method: mouseDrag

  kiss.event.on 
    channel: "mouseDragStop"
    method: mouseDragStop

  kiss.event.on 
    channel: "moveDragOver"
    method: moveDragOver




$("#dragme").on "mousedown", (e)->
  me = $(@)
  initial =
    left: parseFloat(me.css("left"))
    top: parseFloat(me.css("top"))

  me.css
    "pointer-events": "none"

  drop = $("#dropme")

  moveDragOver = ({event, element})->
    if drop[0] == element
      drop.css
        background: "black"
    else
      drop.css
        background: "green"


  mouseDrag = ({event, delta})->
    me.css
      left: initial.left + delta.x
      top: initial.top + delta.y

  mouseDragStop = ({event, delta})->
    me.css
      left: initial.left
      top: initial.top

    me.css
      "pointer-events": ""

    kiss.event.off 
      channel: "mouseDrag"
      method: mouseDrag

    kiss.event.off 
      channel: "mouseDragStop"
      method: mouseDragStop

    kiss.event.off 
      channel: "moveDragOver"
      method: moveDragOver

  kiss.event.on 
    channel: "mouseDrag"
    method: mouseDrag

  kiss.event.on 
    channel: "mouseDragStop"
    method: mouseDragStop

  kiss.event.on 
    channel: "moveDragOver"
    method: moveDragOver
