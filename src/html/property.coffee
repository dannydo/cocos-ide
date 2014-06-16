BorderNode = cc.Node.extend
  onEnter: ->
    @_super()
    @.setZOrder(1000)
    @widthScaleHandle = 10
    @heightScaleHandle = 10

    @_deltaRotation = 0
    @_flagScale = false

    @_point =
      origin: cc.p(0,0)
      destination: cc.p(10, 10)
      color: cc.color(255,255,255,0)
      lineWidth: 1
      fillColor: cc.color(255,255,255,255)

    window.BorderNode = @
    @drawNodeRect = new cc.DrawNode()
    #@addChild @drawNodeRect
    
    listenerHandle = cc.EventListener.create
      event: cc.EventListener.TOUCH_ONE_BY_ONE
      swallowTouches: true
      onTouchBegan: (touch, event) =>
        @handle = event.getCurrentTarget()

        locationInNode = @handle.convertToNodeSpace(touch.getLocation())
        rectSize = @handle.getContentSize()
        rect = cc.rect(0, 0, rectSize.width, rectSize.height)
        
        if cc.rectContainsPoint(rect, locationInNode)
          if (@handle.tag == "rotationHandle")
            $('#gameCanvas').attr('style', 'cursor:move')
          else if @handle.tag == "scaleHandleRightTop" or @handle.tag == "scaleHandleLeftBottom"
            $('#gameCanvas').attr('style', 'cursor:ne-resize')
          else
            $('#gameCanvas').attr('style', 'cursor:nw-resize')

          return true

        return false
      
      onTouchMoved: (touch, event) =>
        @_pointMoved = touch.getLocation()
        @_pointMoved.x -= @active.getParent().x
        @_pointMoved.y -= @active.getParent().y

        if (@handle.tag == "rotationHandle")
          @actionRotation()
        else
          @actionScale()


      onTouchEnded: (touch, event) =>
        
        $('#gameCanvas').attr('style', '')

    iCount = 0
    for point in ["scaleHandleLeftTop","scaleHandleLeftBottom","scaleHandleRightTop","scaleHandleRightBottom","rotationHandle"]
      @[point] = new cc.DrawNode()
      @[point].drawRect(@_point.origin, @_point.destination, @_point.color, @_point.lineWidth, @_point.fillColor)
      @[point].width = @widthScaleHandle;
      @[point].height = @heightScaleHandle;
      @[point].tag = point
      @addChild @[point]
      cc.eventManager.addListener(listenerHandle.clone(), @[point]);
 
  updateLayout:(@active, @scope, ignore=false)->
    if @active
      @x = @active.x
      @y = @active.y
      @anchorX = @active.anchorX
      @anchorY = @active.anchorY
      @rotation = @active.rotation

      deltaX = @widthScaleHandle/2
      deltaY = @heightScaleHandle/2
      
      originX = @active.width*@active.scaleX*@active.anchorX
      originY = @active.height*@active.scaleY*@active.anchorY

      destinationX  = @active.width*@active.scaleX - originX
      destinationY = @active.height*@active.scaleY - originY

      pointRect =
        origin: cc.p(-originX, -originY)
        destination: cc.p(destinationX, destinationY)
        background: cc.color(0,0,0,0)
        lineWidth: 2
        fillColor: cc.color(255,0,0,255)

      @drawNodeRect.clear()
      @drawNodeRect.drawRect(pointRect.origin, pointRect.destination, pointRect.background, pointRect.lineWidth, pointRect.fillColor)

      @scaleHandleLeftTop.x = -deltaX - originX
      @scaleHandleLeftTop.y = destinationY - deltaY

      @scaleHandleLeftBottom.x = -deltaX - originX
      @scaleHandleLeftBottom.y = -deltaY - originY

      @scaleHandleRightTop.x = destinationX - deltaX
      @scaleHandleRightTop.y = destinationY - deltaY

      @scaleHandleRightBottom.x = destinationX - deltaX
      @scaleHandleRightBottom.y = -deltaY - originY

      @rotationHandle.x = destinationX/2 - originX/2 - deltaX
      @rotationHandle.y = destinationY - deltaY

      if not ignore
        cs._nodeChange()

  actionScale:()->
    isBottom = @handle.tag.lastIndexOf("B") > 0
    isLeft = @handle.tag.lastIndexOf("L") > 0

    rotation = @active.rotation / 180  * Math.PI
    cos_rotation = Math.cos(rotation)
    sin_rotation = Math.sin(rotation)

    pointMoveRotation =
      x : (@_pointMoved.x * cos_rotation - @_pointMoved.y * sin_rotation)
      y : (@_pointMoved.x * sin_rotation + @_pointMoved.y * cos_rotation)

    pointActiveRotation =
      x : (@active.x * cos_rotation - @active.y * sin_rotation)
      y : (@active.x * sin_rotation + @active.y * cos_rotation)

    delta = 
      x : pointActiveRotation.x - pointMoveRotation.x
      y : pointActiveRotation.y - pointMoveRotation.y

    offset = 
      x: 0
      y: 0

    if not isBottom then offset.y = 1
    if not isLeft then offset.x = 1

    if ((@active.anchorX == 0 and offset.x == 0) or (@active.anchorX == 1 and offset.x == 1))
      @active.scaleX =  (delta.x + @active.width) / @active.width
    else
      @active.scaleX =  delta.x / (@active.anchorX * @active.width - @active.width * offset.x)

    if ((@active.anchorY == 0 and offset.y == 0) or (@active.anchorY == 1 and offset.y == 1))
      @active.scaleY =  (delta.y + @active.height) / @active.height
    else
      @active.scaleY =  delta.y / (@active.anchorY * @active.height - @active.height * offset.y)

    @updateLayout(@active, @scope)
    @scope.$apply()
    cs._nodeChange()

  actionRotation:()->
    @active.rotation = @getAngle(@active.getPosition(), @_pointMoved)
    @rotation = @active.rotation
    @scope.$apply()
    cs._nodeChange()


  getAngle:(pointA, pointB)->
    deltaX = pointB.x - pointA.x
    deltaY = pointB.y - pointA.y
    return (360 - (Math.atan2(deltaY,deltaX) * 180/Math.PI) + 90) % 360

window.BorderNode = BorderNode