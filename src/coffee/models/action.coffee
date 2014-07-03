class kiss.Action extends cc.ActionInterval
  @properties : [
    "x"
    "y"
    "anchorY"
    "anchorX"
    "skewX"
    "skewY"
    "scaleY"
    "scaleX"
    "rotation"
    "rotationX"
    "rotationY"
    "vertexZ"
    "zIndex"
    "opacity"
    "color"
  ]

  @defaultProperties:
    x : 0
    y : 0
    anchorX : 0.5
    anchorY : 0.5
    scaleX : 1
    scaleY : 1
    skewX: 0
    skewY: 0
    rotationX: 0
    rotationY: 0
    rotation: 0
    zIndex: 0
    opacity: 255
    color: 
      r: 255
      g: 255
      b: 255

  @copyProperties: (node)->
    properties = {}
    for key, value of @defaultProperties
      properties[key] = 
        start: node[key]
        tween: "Linear"

    for key in ["r","g","b"]
      properties[key] = 
        start: node.color[key]
        tween: "Linear"

    delete properties["color"]
    properties

  @Tween : {}

  constructor: ({@animations}={})->
    super()
    if not @animations?
      @animations = []
    @repeat = false;
    @_animationIndex = 0
    @_initialize()

  _initialize:()->
    @_actionList = []
    @_expand()
    @_tags = {}

  _setup:()->
    node = @animations[@_animationIndex]
    for parameter, action of node.actions

      target = @target.getChildByTag node.tag
      if target
        target.updateObjectState {objectState: node.objectState}

        if kiss.Action.defaultProperties.color[action.parameter]?
          color = target.color
          color[parameter] = result
          target.setColor color
        else
          target[parameter] = action.start

        if action.end? and action.start != action.end 
          clone = _.clone action
          clone.target = target
          clone.parameter = parameter

          @_actionList.push clone

  _expand:()->
    nodes = {}
    @animations.sort (a,b)-> a.time - b.time

    for node in @animations
      for parameter, action of node.actions
        if not nodes[node.tag]? 
           nodes[node.tag] = {}
        
        if nodes[node.tag][parameter]?
          if nodes[node.tag][parameter].start == action.start
            delete nodes[node.tag][parameter].startTime
            delete nodes[node.tag][parameter].endTime
            delete nodes[node.tag][parameter].end
          else
            nodes[node.tag][parameter].endTime = node.time
            nodes[node.tag][parameter].end = action.start

        nodes[node.tag][parameter] = action
        action.startTime = node.time

    for name, node of nodes
      for parameter, action of node
        delete action.startTime
        delete action.endTime
        delete action.end

    if @animations.length == 0
      @_duration = 0
    else
      @_duration = @animations[@animations.length-1].time

  _debug:()->
    for animations in @animations
      for node in animations.nodes
        console.log node

  _collapse:()->
    for node in @animations
      for parameter, action of node.actions
        delete action.startTime
        delete action.endTime
        delete action.end
  
  #update:(time)->
  #  console.log("uPDATE")

  step:(dt)->
    if @_firstTick
        @_animationIndex = 0
    super(dt)

    index = @_animationIndex
    while index != @animations.length and @animations[index] and
        @_elapsed >= @animations[index].time
      @_setup()
      @_animationIndex = ++index

    expiredAction = [] 
    for action in @_actionList
      action.time = @_elapsed
      {result, isDone} = kiss.Action.Tween[action.tween](action)

      if isDone
        expiredAction.push action

      if kiss.Action.defaultProperties.color[action.parameter]?
        color = action.target.color
        color[action.parameter] = result
        action.target.setColor color
      else
        action.target[action.parameter] = result

    if @repeat and @isDone()
      @_elapsed = 0
      @_animationIndex = 0

    _.pull @_actionList, expiredAction...

  setTime:(@target, time=0)->
    if time < @_elapsed
      @_firstTick = false
      @_animationIndex = 0
      @_actionList = []
      @_tags['global'] = target
      @_elapsed = 0
    @step time - @_elapsed

  startWithTarget: (@target)->
    @_actionList = []
    @_tags = []
    @_tags['global'] = target
    super(target)


kiss.Action.Tween.Linear = ({time, startTime, endTime, start, end})->
  if startTime <= time <= endTime
    result: (time - startTime) / (endTime - startTime) * (end - start) + start
    isDone: false
  else
    result: end
    isDone: true
