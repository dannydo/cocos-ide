class CocosStudio 
  constructor: ->
    canvas = oCanvas.create 
      canvas: "#canvas"
    @timeLine = new ci.TimeLine(canvas);
    @_bind()
    @_setupPanelManager();
    @_frameRate = 60

  _bind:()->
    $(window).on "resize", => @resize
    @ciMain = $(".ciMain")
    @ciMiddle = $(".ciMiddle", @ciMain)
    @ciMiddle.ciContent = $(".ciMiddle > .ciContent", @ciMain)
    @ciTop = $(".ciTop", @ciMain)
    @ciBottom = $(".ciBottom", @ciMain)
    @ciLeft = $(".ciLeft", @ciMain)
    @ciRight = $(".ciRight", @ciMain)

    @ciTimeLine = $(".ciTimeLine", @ciBottom)
    @ciAnimationList = $(".ciAnimationList", @ciBottom)
    @ciTweenList = $(".ciTweenList", @ciBottom)
    @ciCanvas = $("canvas#gameCanvas")

  _cocos2dxReady:({@layer})->
    @timeLine.knob.layer.bind "knob-update", @_knobUpdate
    @timeLine.knob.layer.bind "knob-delete", @_knobDelete
    @timeLine.knob.layer.bind "knob-added", @_knobAdded
    @timeLine.hoverIndicator.layer.bind "hover-frame-selected", @_hoverFrameSelected
    console.log "finish-loading"

  _updateKnobTimeline:()->
    @timeLine.knob.removeAllKnob()

    for node in sa.animations
      child = MainLayer.getChildByTag node.tag
      knob = @timeLine.knob.createKnob
        position:
          row: child.row
          col: Math.round node.time * @_frameRate
      knob._userData = node

    @timeLine.knob._clearSelection()
    @timeLine.hoverIndicator.hoverIndicator.redraw()

  _hoverFrameSelected:(event)=>
    if MainLayer
      sa.setTime MainLayer, event.originalEvent.col / @_frameRate
      event = ""
      for knob in @timeLine.knob._list
        if knob.col == @timeLine.hoverIndicator.col and knob._userData?
          MainLayer.objectState = _.clone knob._userData.objectState
          event = _.clone knob._userData.event
      
      if MainLayer.layerRow and MainLayer.layerRow[@timeLine.hoverIndicator.row]
        MainLayer.active = MainLayer.spriteNode[MainLayer.layerRow[@timeLine.hoverIndicator.row]]
        MainLayer.active.event = event
        kiss.event.emit
          channel: "mainLayer.updateLayoutBoder"
          parameter: {elementActive:MainLayer.active, isNodeChange:false}
      
  _knobAdded:(event)=>
    knob = event.originalEvent.added

    if MainLayer.layerRow? and MainLayer.layerRow.length > knob.row
      knob._userData = 
        time: 0
        tag: MainLayer.layerRow[knob.row]
        sprite: MainLayer.spriteNode[MainLayer.layerRow[knob.row]].frameName  
        actions: {}
        objectState: _.clone MainLayer.objectState

      if MainLayer.active? 
        knob._userData.actions = kiss.Action.copyProperties MainLayer.active

      knob._userData.time = knob.col / @_frameRate
      sa.animations.push knob._userData
    else
      knob.remove()
      @timeLine.hoverIndicator.hoverIndicator.redraw()


  _knobDelete:(event)=>
    for knob in event.originalEvent.deleted
      _.pull sa.animations, knob._userData

  _knobUpdate:(event)=>
    for knob in event.originalEvent.manager._list
      if knob._userData? and knob._userData.time * @_frameRate != knob.col
        knob._userData.time = knob.col / @_frameRate 

  _playAnimation:()->
    if MainLayer.active
      sa._expand()
      sa.repeat = false
      MainLayer.actionManager.removeAllActionsFromTarget MainLayer
      MainLayer.runAction(sa)
      @timeLine.hoverIndicator.setPosition 0, @timeLine.hoverIndicator.row

  _loopAnimation:()->
    if MainLayer.active
      sa._expand()
      sa.repeat = true
      MainLayer.actionManager.removeAllActionsFromTarget MainLayer
      MainLayer.runAction(sa)

  _pauseAnimation:()->
    if MainLayer.active
      MainLayer.active.actionManager.removeAllActionsFromTarget MainLayer

  _stopAnimation:()->
    if MainLayer.active
      MainLayer.active.actionManager.removeAllActionsFromTarget MainLayer


  _nodeChange:(selectedObject)->

    if MainLayer.active?
      index = "#{@timeLine.hoverIndicator.col}:#{MainLayer.active.row}"
      if @timeLine.knob._index[index]?
        knob = @timeLine.knob._index[index]
        knob._userData.actions = kiss.Action.copyProperties MainLayer.active

        MainLayer.active.updateObjectState({objectState: MainLayer.objectState})

        knob._userData.sprite = MainLayer.active.frameName
        knob._userData.objectState = _.clone MainLayer.objectState
        knob._userData.event = MainLayer.active.event

        sa._expand()
      else
        knob = @timeLine.knob.createKnob
          position:
            row: MainLayer.active.row
            col: @timeLine.hoverIndicator.col
        knob._userData = 
          time        : @timeLine.hoverIndicator.col / @_frameRate
          tag         : MainLayer.active.tag
          sprite      : MainLayer.active.frameName
          actions     : kiss.Action.copyProperties MainLayer.active
          objectState : _.clone MainLayer.objectState

        sa.animations.push knob._userData
        sa._expand()

  _setupPanelManager:()->
    @pm = pm = new PanelManager()
    pm.addPanel @ciTop, @ciMiddle, @ciMain, "top"
    pm.addPanel @ciBottom, @ciMiddle, @ciMain, "bottom"
    pm.addPanel @ciLeft, @ciMiddle.ciContent, @ciMain, "left"
    pm.addPanel @ciRight, @ciMiddle.ciContent, @ciMain, "right"

    pm.addPanel @ciAnimationList, @ciTimeLine, @ciMain, "left"
    pm.addPanel @ciTweenList, @ciTimeLine, @ciMain, "right"

    $("#gameCanvas").on "mousemove", (e)=> pm.mouseMove(e)

    pm._onchange.push ()=>
        canvas.height = @ciTimeLine.height()
        canvas.width = @ciTimeLine.innerWidth()

        @ciCanvas[0].height = @ciMiddle.ciContent.height()
        @ciCanvas[0].width = @ciMiddle.ciContent.innerWidth()

        @timeLine.ocanvas.width = @ciTimeLine.innerWidth()
        @timeLine.ocanvas.height = @ciTimeLine.height()

        if cc.view?
          cc.view.setDesignResolutionSize( @ciCanvas[0].width, @ciCanvas[0].height, cc.ResolutionPolicy.SHOW_ALL)
          if window.MainLayer?
            window.MainLayer.x = @ciCanvas[0].width / 2 
            window.MainLayer.y = @ciCanvas[0].height /2

    pm.reset()

window.cs = new CocosStudio(); 
