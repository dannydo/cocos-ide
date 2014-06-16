root = global ? window

class root.ScrollBar extends root.Ui
  constructor:({@name, @type})->
    @_configure()
    @_initialize()
    @_applyStyling()
    @_registerEvent()
    @_bind()
    super arguments...

  _configure: ()->
    @value =
      current : 0
      min     : 0
      max     : 1000
      frame   : 50
    @size = {}

    if @type == "horizontal"
      @_horizontalConfiguration()
    else
      @_verticalConfiguration()

    @config = 
      background:
        default : "#eee"
      handle:
        default : "#999"
        hover   : "#bbb"
        click   : "#000"
        size    : 16
        stroke  : ""
      body:
        default : "#aaa"
        hover   : "#ccc"
        click   : "#000"
        size    : 16*3
        minSize : 16*3
        maxSize : -16

  _verticalConfiguration:()->
    @positionType = "y"
    @otherPositionType = "x"

    @sizeType = "height"
    @otherSizeType = "width"

  _horizontalConfiguration:()->
    @positionType = "x"
    @otherPositionType = "y"

    @sizeType = "width"
    @otherSizeType = "height"

  _initialize:()->
    @background       = paper.rect 0, 0, 0, 0
    @body             = paper.rect 0, 0, 0, 0
    @head             = paper.rect 0, 0, 0, 0
    @tail             = paper.rect 0, 0, 0, 0

    @background.userData = @config.background
    @head.userData       = @config.handle
    @tail.userData       = @config.handle
    @body.userData       = @config.body

    @head.userObject = @
    @body.userObject = @
    @tail.userObject = @

  _applyStyling:()->
    @background.attr 
      fill: @background.userData.default
    @head.attr 
      fill: @head.userData.default
    @tail.attr 
      fill: @tail.userData.default
    @body.attr 
      fill: @body.userData.default

  _registerEvent:()->
    hoverParameters = [
        ->
          if not @userData.draging?
            @attr 
              fill : @userData.hover
          @userData.hovering = true
        ->
          if not @userData.draging?
            @attr 
              fill : @userData.default
          @userData.hovering = false
      ]

    @head.hover hoverParameters...
    @body.hover hoverParameters...
    @tail.hover hoverParameters...

    dragParameters = [
        (x, y, e)->
          @attr 
            fill : @userData.click
          @userData.draging = @attrs[@userObject.positionType]
        (e)->
          if @userData.hovering
            @attr 
              fill : @userData.hover
          else
            @attr 
              fill : @userData.default
          delete @userData.draging
      ]

    @head.drag [
        (x, y, dx, dy, e)=>
          mousePosition = 
            x: x
            y: y
          value = @head.userData.draging + mousePosition[@positionType]
          min = @size[@positionType]
          max = @tail.attrs[@positionType] + @tail.attrs[@sizeType] - 
            @body.userData.minSize

          position = _.clamp value, min, max
          
          @_value
            frame : ((@tail.attrs[@positionType] - position + 
                     @tail.attrs[@sizeType]) / @size[@sizeType]) * @value.max
          
        dragParameters...
      ]...

    @tail.drag [
        (x, y, dx, dy, e)=>
          mousePosition = 
            x: x
            y: y
          
          value = @tail.userData.draging + mousePosition[@positionType]
          min   = @body.attrs[@positionType] + @body.userData.minSize - 
            @tail.attrs.width
          max   = @size[@sizeType] - @tail.attrs[@sizeType] + 
                    @size[@positionType]

          position = _.clamp value, min, max 

          console.log position

          @_value
            frame : @value.max * ((position - @head.attrs[@positionType] + 
              @tail.userData.size) / @size[@sizeType]) 

        dragParameters...        
      ]...
   
    @body.drag [
        (x, y, dx, dy, e)=>
          mousePosition = 
            x: x
            y: y
          
          value = @body.userData.draging + mousePosition[@positionType]
          min   = @size[@positionType]
          max   = @size[@positionType] + @size[@sizeType] - 
                    @body.attrs[@sizeType]
          
          position = _.clamp value, min, max

          @_value
            current : (position - @size[@positionType]) / 
              (@size[@sizeType] - @body.attrs[@sizeType]) * @value.max
          
        dragParameters...        
      ]...

  _bind:()->
    if @name?
      kiss.event.on 
        channel: "#{@name}.value"
        method: => @_value(arguments...)
      kiss.event.on 
        channel: "#{@name}.resize"
        method: => @_resize(arguments...)


  _value:({min, max, frame, current, refreshIgnore}={})->
    changed = false
    if min? and min.toFixed(4) != @value.min.toFixed(4)
      @value.min = min
      changed = true

    if max? and max.toFixed(4) != @value.max.toFixed(4)
      @value.max = max
      changed = true

    if current? and current.toFixed(4) != @value.current.toFixed(4)
      @value.current = current
      changed = true

    if frame? and frame.toFixed(4) != @value.frame.toFixed(4)
      @value.frame = frame
      changed = true

    if not refreshIgnore? and changed
      @_applySizing()
      mediator.emit "#{@name}.onValue", _.clone @value

  _applySizing: ()->
    value = @value.frame / @value.max * @size[@sizeType] 
    min   = @body.userData.minSize 
    max   = @size[@sizeType] + @body.userData.maxSize
    bodySize = Math.round _.clamp value, min, max

    bodyPosition = @size[@positionType] + 
      Math.round @value.current / @value.max * (@size[@sizeType] - bodySize)

    bodyParameters = {}
    bodyParameters[@positionType]      = bodyPosition
    bodyParameters[@otherPositionType] = @size[@positionType]
    bodyParameters[@otherSizeType]     = @size[@otherSizeType] 
    bodyParameters[@sizeType]          = bodySize
    @body.attr bodyParameters

    headParameters = {}
    headParameters[@positionType]      = @body.attrs[@positionType]
    headParameters[@otherPositionType] = @size[@positionType] 
    headParameters[@otherSizeType]     = @size[@otherSizeType]
    headParameters[@sizeType]          = @head.userData.size
    @head.attr headParameters

    tailParameters = {}
    tailParameters[@positionType]      = @body.attrs[@positionType] + 
      @body.attrs[@sizeType] - @tail.userData.size
    tailParameters[@otherPositionType] = @size[@positionType]
    tailParameters[@otherSizeType]     = @size[@otherSizeType]
    tailParameters[@sizeType]          = @tail.userData.size
    @tail.attr tailParameters

    @background.attr
      x: @size.x
      y: @size.y
      height: @size.height
      width: @size.width













sb = new root.ScrollBar
  name: "hotdogs"
  type: "horizontal"

kiss.event.emit
  channel: "hotdogs.value"
  parameter: {min: 100,max: 1000,current: 500,frame: 250}

kiss.event.emit 
  channel: "hotdogs.resize"
  parameter:
    x: 100
    y: 100
    width: 1000
    height: 16

