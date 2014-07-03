MainScene = cc.Scene.extend
  onEnter: ->
    @_super()
    @addChild new MainLayer()
    window.MainScene = @


MainLayer = cc.Layer.extend
  onEnter: ->
    @_super()

    screenSize = cc.director.getWinSize();
    #@_ignoreAnchorPointForPosition = false
    @x = screenSize.width / 2;
    @y = screenSize.height / 2;
    #@anchorX = -0.5
    #@anchorY = -0.5

    window.MainLayer = @

    @drawingNode = new cc.DrawNode()
    @lineColor = cc.color(255, 0,255,255)
    @drawingNode.drawSegment(cc.p(5000,0), cc.p(-5000,0), 1, @lineColor)
    @drawingNode.drawSegment(cc.p(0,5000), cc.p(0,-5000), 1, @lineColor)
    @addChild @drawingNode


    window.sa = new kiss.Action()

    @borderNode = new kiss.BorderNode
      bindingName : "borderNode"
    @addChild @borderNode

    @property = new kiss.Property
      bindingName: "property"

    @standardEvent = cc.EventListener.create
      event: cc.EventListener.TOUCH_ONE_BY_ONE
      swallowTouches: true
      onTouchBegan: (touch, event) => 
        target = event.getCurrentTarget()

        locationInNode = target.convertToNodeSpace(touch.getLocation());   
        s = target.getContentSize()
        rect = cc.rect(0, 0, s.width, s.height)
               
        if cc.rectContainsPoint(rect, locationInNode)
          @active = target

          kiss.event.emit
            channel: "mainLayer.updateLayoutBoder"
            parameter: {elementActive:@active, isNodeChange:true}

          return true
        else if @active?
          @active = null
          
          kiss.event.emit
            channel: "mainLayer.updateLayoutBoder"
            parameter: {elementActive:@active, isNodeChange:true}

        return false
      
      onTouchMoved: (touch, event) =>         
        target = event.getCurrentTarget()
        if target.lock
          return;

        delta = touch.getDelta()
        target.x += delta.x
        target.y += delta.y

        @borderNode.x += delta.x
        @borderNode.y += delta.y

        position =
          x : target.x
          y : target.y
        kiss.event.emit
          channel: "borderNode.updatePropertyPosition"
          parameter: position
      
      onTouchEnded: (touch, event) =>
        cs._nodeChange(@selectedObject)
      
    if cs?
      cs._cocos2dxReady(@)

    kiss.event.on 
      channel:"objectList.onSelectObject" 
      method: (selectedObject)=> @onSelectObject(selectedObject)

    kiss.event.on 
      channel:"objectList.onSelectAnimation" 
      method: (selectedAnimation)=> @onSelectAnimation(selectedAnimation)

    kiss.event.on 
      channel:"property.onChangeObjectStateVariable"
      method: (objectState)=> 
        @objectState = objectState;
        @active.updateObjectState({objectState: objectState})

        kiss.event.emit
          channel: "mainLayer.updateLayoutBoder"
          parameter: {elementActive:@active, isNodeChange:true}


  onSelectObject:(selectedObject)->
    @selectedObject = selectedObject
    sa.animations = []
    cs._updateKnobTimeline()

    @active = null
    kiss.event.emit
      channel: "mainLayer.updateLayoutBoder"
      parameter: {elementActive:@active, isNodeChange:true}

    if @spriteNode?
      for k, v of @spriteNode
        v.removeFromParentAndCleanup()

    @layerRow = []
    @spriteNode = {}
    for layerName, data of selectedObject.layers
      @layerRow.push layerName
      @objectState = _.clone selectedObject.variableDefault

      @active = kiss.Node.getSpriteNode
        selectedObject: selectedObject
        layerName:layerName
        objectState: selectedObject.variableDefault

      if @active
        @active.setTag layerName
        @active.row = @layerRow.length - 1
        
        @spriteNode[layerName] = @active
  
        cc.eventManager.addListener(@standardEvent.clone(), @active);
        @addChild @active

  onSelectAnimation:(selectedAnimation)->
    if selectedAnimation.length > 0
      sa.animations = selectedAnimation
      cs._updateKnobTimeline()
    else
      kiss.event.emit
        channel: "mainLayer.updateLayoutBoder"
        parameter: {elementActive:null, isNodeChange:true}

      sa.animations = selectedAnimation
      cs._updateKnobTimeline()



window.MainScene = MainScene
