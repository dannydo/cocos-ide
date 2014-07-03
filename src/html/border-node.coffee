class kiss.BorderNode extends cc.Node
  constructor: ({@bindingName})->
    super()

    @.visible = false
    @_bind()
    @_resetDataProperty()

    @.setZOrder(1000)
    @_widthScaleHandle = 10
    @_heightScaleHandle = 10

    @_deltaRotation = 0
    @_flagScale = false

    @_rotationAngles = []
    @_countRotationCircle = 0;

    @_point =
      origin: cc.p(0,0)
      destination: cc.p(10, 10)
      fillColor: cc.color(255,255,255,255)
      lineWidth: 1
      lineColor: cc.color(255,255,255,255)

    @_drawNodeRect = new cc.DrawNode()
    @addChild @_drawNodeRect
    
    listenerHandle = cc.EventListener.create
      event: cc.EventListener.TOUCH_ONE_BY_ONE
      swallowTouches: true
      onTouchBegan: (touch, event) =>
        if @elementActive?
          @_handle = event.getCurrentTarget()

          locationInNode = @_handle.convertToNodeSpace(touch.getLocation())
          rectSize = @_handle.getContentSize()
          rect = cc.rect(0, 0, rectSize.width, rectSize.height)
          
          if cc.rectContainsPoint(rect, locationInNode)
            if (@_handle.tag == "_rotationHandle")
              $('#gameCanvas').attr('style', 'cursor:move')

              @_pointMoved = touch.getLocation()
              @_pointMoved.x -= @elementActive.getParent().x
              @_pointMoved.y -= @elementActive.getParent().y

              point = @_rotationHandle.getPosition()
              point.x += @elementActive.x
              point.y += @elementActive.y
              @_deltaAngle = @_getAngle(@elementActive.getPosition(), point);
              
              @_rotationAngles = []
              if @elementActive.rotation >= 0
                @_rotationAngles.push(@elementActive.rotation%360)
              else
                if @elementActive.rotation%360 == 0
                  @_rotationAngles.push(0)  
                else
                  @_rotationAngles.push(360 + @elementActive.rotation%360)

            else if @_handle.tag == "_scaleHandleRightTop" or @_handle.tag == "_scaleHandleLeftBottom"
              $('#gameCanvas').attr('style', 'cursor:ne-resize')
            else
              $('#gameCanvas').attr('style', 'cursor:nw-resize')

            return true

        return false
      
      onTouchMoved: (touch, event) =>
        @_pointMoved = touch.getLocation()
        @_pointMoved.x -= @elementActive.getParent().x
        @_pointMoved.y -= @elementActive.getParent().y

        if (@_handle.tag == "_rotationHandle")
          @_actionRotation()
        else
          @_actionScale()

      onTouchEnded: (touch, event) =>
        $('#gameCanvas').attr('style', '')

    iCount = 0
    for point in ["_scaleHandleLeftTop","_scaleHandleLeftBottom","_scaleHandleRightTop","_scaleHandleRightBottom","_rotationHandle"]
      @[point] = new cc.DrawNode()
      @[point].drawRect(@_point.origin, @_point.destination, @_point.fillColor, @_point.lineWidth, @_point.lineColor)
      @[point].width = @_widthScaleHandle;
      @[point].height = @_heightScaleHandle;
      @[point].tag = point
      @addChild @[point]
      cc.eventManager.addListener(listenerHandle.clone(), @[point]);
 
  _actionScale:()->
    isBottom = @_handle.tag.lastIndexOf("B") > 0
    isLeft = @_handle.tag.lastIndexOf("L") > 0

    rotation = @elementActive.rotation / 180  * Math.PI
    cos_rotation = Math.cos(rotation)
    sin_rotation = Math.sin(rotation)

    pointMoveRotation =
      x : (@_pointMoved.x * cos_rotation - @_pointMoved.y * sin_rotation)
      y : (@_pointMoved.x * sin_rotation + @_pointMoved.y * cos_rotation)

    pointActiveRotation =
      x : (@elementActive.x * cos_rotation - @elementActive.y * sin_rotation)
      y : (@elementActive.x * sin_rotation + @elementActive.y * cos_rotation)

    delta = 
      x : pointActiveRotation.x - pointMoveRotation.x
      y : pointActiveRotation.y - pointMoveRotation.y

    offset = 
      x: 0
      y: 0

    if not isBottom then offset.y = 1
    if not isLeft then offset.x = 1

    if ((@elementActive.anchorX == 0 and offset.x == 0) or (@elementActive.anchorX == 1 and offset.x == 1))
      @elementActive.scaleX =  (delta.x + @elementActive.width) / @elementActive.width
    else
      @elementActive.scaleX =  delta.x / (@elementActive.anchorX * @elementActive.width - @elementActive.width * offset.x)

    if ((@elementActive.anchorY == 0 and offset.y == 0) or (@elementActive.anchorY == 1 and offset.y == 1))
      @elementActive.scaleY =  (delta.y + @elementActive.height) / @elementActive.height
    else
      @elementActive.scaleY =  delta.y / (@elementActive.anchorY * @elementActive.height - @elementActive.height * offset.y)

    @_updateLayoutBoder(true)

    @_scale =
      x : @elementActive.scaleX
      y : @elementActive.scaleY
    kiss.event.emit 
      channel: "#{@bindingName}.onScale"
      parameter: @_scale

  _actionRotation:()->
    angle = @_getAngle(@elementActive.getPosition(), @_pointMoved)
    realAngle = angle - @_deltaAngle
    if realAngle < 0
      realAngle += 360

    @_rotationAngles.push(realAngle)
    @_calculatorRotationCircle()

    @elementActive.rotation = realAngle + @_countRotationCircle*360
    @.rotation = @elementActive.rotation
    cs._nodeChange()

    kiss.event.emit 
      channel: "#{@bindingName}.onRotation"
      parameter: @.rotation

  _getAngle:(pointA, pointB)->
    deltaX = pointB.x - pointA.x
    deltaY = pointB.y - pointA.y
    return (360 - (Math.atan2(deltaY,deltaX) * 180/Math.PI)) % 360

  _calculatorRotationCircle:()->
    if @_rotationAngles.length > 1
      for index in [(@_rotationAngles.length-1)..1]
        deltaAngle = @_rotationAngles[index-1] - @_rotationAngles[index]
        if Math.abs(deltaAngle) > 270
          @_countRotationCircle += deltaAngle/(Math.abs(deltaAngle))
          @_rotationAngles = []
          break

  _bind:()->
    if @bindingName?
      kiss.event.on
        channel: "mainLayer.updateLayoutBoder"
        method: ({@elementActive, isNodeChange})=>
          @_updateLayoutBoder(isNodeChange)

      kiss.event.on
        channel: "property.onChange"
        method: (dataProperties) =>
          @_propertyChange(dataProperties)

      kiss.event.on
        channel: "colorpicker.onSelectColor"
        method: (color)=>
          activeColor = @elementActive.color
          activeColor.r = color.r
          activeColor.g = color.g
          activeColor.b = color.b
          @elementActive.color = activeColor

  _propertyChange:(dataProperties)->
      @elementActive.x = dataProperties.position.x
      @elementActive.y = dataProperties.position.y

      @elementActive.skewX = dataProperties.skew.x
      @elementActive.skewY = dataProperties.skew.y

      @elementActive.scaleX = dataProperties.scale.x
      @elementActive.scaleY = dataProperties.scale.y

      @elementActive.anchorX = dataProperties.anchor.x
      @elementActive.anchorY = dataProperties.anchor.y

      @_countRotationCircle = Math.round(@_dataProperties.rotation/360 + 0.5) - 1
      @elementActive.rotation  = dataProperties.rotation
      @elementActive.zIndex    = dataProperties.zIndex
      @elementActive.opacity   = dataProperties.transparency

      @elementActive.visible = dataProperties.visible
      @elementActive.lock    = dataProperties.lock
      @elementActive.event    = dataProperties.event

      @_updateLayoutBoder(true)

  _updateLayoutBoder:(isNodeChange)->
    if (@elementActive)
      @_countRotationCircle = Math.round(@elementActive.rotation/360 + 0.5) - 1

      @.x         = @elementActive.x
      @.y         = @elementActive.y
      @.anchorX   = @elementActive.anchorX
      @.anchorY   = @elementActive.anchorY
      @.rotation  = @elementActive.rotation

      deltaX = @_widthScaleHandle / 2
      deltaY = @_heightScaleHandle / 2

      width  =  @elementActive.width * @elementActive.scaleX
      height = @elementActive.height * @elementActive.scaleY
      
      originX = width * @elementActive.anchorX
      originY = height * @elementActive.anchorY

      destinationX = width - originX
      destinationY = height - originY

      pointRect =
        origin: cc.p(-originX, -originY)
        destination: cc.p(destinationX, destinationY)
        fillColor: cc.color(255,255,255,-255)
        lineWidth: 2
        lineColor: cc.color(255,0,0,255)

      @_drawNodeRect.clear()
      @_drawNodeRect.drawRect(pointRect.origin, pointRect.destination, pointRect.fillColor, pointRect.lineWidth, pointRect.lineColor)

      @_scaleHandleLeftTop.x = -deltaX - originX
      @_scaleHandleLeftTop.y = destinationY - deltaY

      @_scaleHandleLeftBottom.x = -deltaX - originX
      @_scaleHandleLeftBottom.y = -deltaY - originY

      @_scaleHandleRightTop.x = destinationX - deltaX
      @_scaleHandleRightTop.y = destinationY - deltaY

      @_scaleHandleRightBottom.x = destinationX - deltaX
      @_scaleHandleRightBottom.y = -deltaY - originY

      @_rotationHandle.x = destinationX/2 - originX/2 - deltaX
      @_rotationHandle.y = destinationY - deltaY

      if isNodeChange == true
        cs._nodeChange()

      @.visible = true
      @_updateDataProperty()
    else
      @.visible = false
      @_resetDataProperty()

    kiss.event.emit
      channel: "#{@bindingName}.setProperties"
      parameter: @_dataProperties

  _updateDataProperty:()->
    if @elementActive?
      @_dataProperties.layerName = @elementActive.layerName
      @_dataProperties.position.x = @elementActive.x
      @_dataProperties.position.y = @elementActive.y

      @_dataProperties.skew.x = @elementActive.skewX
      @_dataProperties.skew.y = @elementActive.skewY

      @_dataProperties.scale.x = @elementActive.scaleX
      @_dataProperties.scale.y = @elementActive.scaleY

      @_dataProperties.anchor.x = @elementActive.anchorX
      @_dataProperties.anchor.y = @elementActive.anchorY

      @_dataProperties.rotation = @elementActive.rotation
      @_dataProperties.zIndex = @elementActive.zIndex
      @_dataProperties.transparency = @elementActive.opacity

      @_dataProperties.color.r = @elementActive.color.r
      @_dataProperties.color.g = @elementActive.color.g
      @_dataProperties.color.b = @elementActive.color.b

      @_dataProperties.visible = @elementActive.visible
      @_dataProperties.lock = @elementActive.lock

      @_dataProperties.objectState = @elementActive.objectState
      @_dataProperties.event = @elementActive.event

  _resetDataProperty:()->
    @_dataProperties = {
      layerName: ""
      position :
        x : ""
        y : ""
      rotation : ""
      skew :
        x : ""
        y : ""
      scale :
        x : ""
        y : ""
      anchor :
        x : ""
        y : ""
      zIndex : ""
      transparency : ""
      color :
        r : 255
        g : 255
        b : 255
      visible : false
      lock : false
      objectState: {}
      event: ""
    }
