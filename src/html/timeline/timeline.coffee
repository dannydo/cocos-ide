class TimeLine
  constructor:(@ocanvas)->
    @zeroOrigin = {x:0, y:0}

    @size =
      x: 20
      y: 40

    @offset =
      x: @size.x
      y: @size.y * 1.5

    @_initialize();

  dragMove:()->
    if @draw.x > 0
      @draw.x = 0
    if @draw.x < - (@draw.width - @ocanvas.width)
      @draw.x = - (@draw.width - @ocanvas.width)
    @draw.y = 0
  dragStart:()->
  dragEnd:()->

  _initialize:()->
    @_createLayers();
    @_bindEvents();

    ci.Knob._initialize 
      parent : @ 
      layer  : @_knobLayer 

    @hoverIndicator = new ci.HoverIndicator 
      parent : @
      layer  : @_segmentLayer

    ci.Segment._initialize 
      parent : @ 
      layer  : @_segmentLayer 

    ci.Lines._initialize 
      parent : @ 
      layer  : @_lineLayer 

    @knob = ci.Knob
    @segment = ci.Segment
    @lines = ci.Lines

  _createLayers: ()->
    @draw = @ocanvas.display.rectangle
      origin: @zeroOrigin
      width: @ocanvas.width * 10
      height: @ocanvas.height * 5
      fill: "#333"

    defaultParamaters = 
      origin: @zeroOrigin

    @_lineLayer = @ocanvas.display.rectangle defaultParamaters
    @_segmentLayer = @ocanvas.display.rectangle defaultParamaters
    @_knobLayer = @ocanvas.display.rectangle defaultParamaters

    @ocanvas.addChild @draw
    @draw.addChild @_lineLayer
    @draw.addChild @_segmentLayer
    @draw.addChild @_knobLayer

  resize:()->
    @draw.trigger "timeLineResize"

  _bindEvents:()->
    ###
    @draw.dragAndDrop
      start: ()=> @dragStart()
      move: ()=> @dragMove()
      end: ()=> @dragEnd()
    ###

window.ci.TimeLine = TimeLine
###
oCanvas.domReady ()->
  canvas = oCanvas.create 
    canvas: "#canvas"
    background: "#0cc"
  timeLine = new TimeLine(canvas);

  resize = ()->
    timeLine.ocanvas.width = $(document.body).width()
    timeLine.ocanvas.height = $(document.body).height()
  
  $(window).on "resize", resize  

  resize()
###

