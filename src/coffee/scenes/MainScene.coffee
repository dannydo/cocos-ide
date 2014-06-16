
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

    # Batch Node for performance but need some bug fixing
    @spritebatch = spritebatch = cc.SpriteBatchNode.create(resource.images.boardPng);
    @addChild spritebatch

    cache = cc.spriteFrameCache
    cache.addSpriteFrames(resource.res.boardPlist);

    window.sa = new kiss.Action()

    @boderNode = new BorderNode()
    @boderNode.setVisible(false)

    @addChild @boderNode


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
          @spritebatch.reorderChild target
          @activeColor = _.clone(@active.color)
          @colorPicker.rgb = @activeColor
          @boderNode.setVisible(true)
          @boderNode.updateLayout(@active, @scope)
          return true
        else if @active?
          @boderNode.setVisible(false)

        return false
      
      onTouchMoved: (touch, event) =>         
        target = event.getCurrentTarget()
        if target.lock
          return;

        delta = touch.getDelta()
        target.x += delta.x
        target.y += delta.y

        @boderNode.x += delta.x
        @boderNode.y += delta.y

        @scope.$apply()
      
      onTouchEnded: (touch, event) =>         
        @scope.$apply()
        cs._nodeChange()
      
    @bootAngularJs();
    if cs?
      cs._cocos2dxReady(@)

  bootAngularJs:()->
    if angular?
      @app = angular.module 'CocosStudio', []
      @rm = @resourceManager = new ResourceManager({app:@app})
      @rm.on
        event:"selectObject" 
        method: (e,p)=> @onSelectObject(e,p)

      @rm.on
        event:"selectAnimation" 
        method: (e,p)=> @onSelectAnimation(e,p)

      @colorPickerClass = new Colorpicker()
      @colorPicker = @colorPickerClass.colorPicker

      @app.controller 'PropertyManager', ['$scope', ($scope) => 
        @scope = $scope;
        @colorPickerClass.setScope(@scope)
        @resourceManager.scope = @scope
        @
      ]
      angular.bootstrap(document, ['CocosStudio']);

  onSelectObject:(resourceManager, parameters)->      
    sa.animations = []

    if @spriteNode?
      for k, v of @spriteNode
        v.removeFromParentAndCleanup()

    @layerRow = []
    @spriteNode = {}

    for layerName, data of @resourceManager.selectedObject.layers
      name = @resourceManager.getObjectState
        layerName:layerName
        combinations: @resourceManager.selectedObject.variableDefault
      name = name.split("/").pop()
      @layerRow.push layerName
      @objectState = _.clone @resourceManager.selectedObject.variableDefault

      if name
        @active = Studio.Node.getSpriteNode name
        @active.setTag layerName
        @active.row = @layerRow.length - 1

        @spriteNode[layerName] = @active
  
        cc.eventManager.addListener(@standardEvent.clone(), @active);
        @addChild @active

  onSelectAnimation:(resourceManager, parameters)->
    [animationName] = parameters
    sa.animations = @resourceManager.selectedObject.animations[animationName]
    cs._updateKnobTimeline()

  selectColor:(rgb)->
    if @active?
      @activeColor = rgb
      @active.color = rgb
    _.defer ->
        $('#colorpicker').addClass('fade').hide()

  applyChangeLayoutBoderNode:()->
    @boderNode.updateLayout(@active, @scope)

  applyActiveColor:()->
    @active.color = @activeColor

window.MainScene = MainScene
