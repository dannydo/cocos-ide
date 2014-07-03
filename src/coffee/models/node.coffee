class kiss.Node extends cc.Sprite
  @_recycleSpriteNode : []

  @getSpriteNode:({selectedObject, layerName, objectState})->
    if not @_recycleSpriteNode.length
      @_recycleSpriteNode.push new @()
 
    sprite = @_recycleSpriteNode.pop()
    sprite.selectedObject = selectedObject
    sprite.layerName = layerName
    sprite.objectState = objectState
    
    frameName = sprite.getObjectState()
    if (frameName)
      sprite.frameName = frameName
      sprite.initWithFile frameName
      sprite.anchorX = 0.5
      sprite.anchorY = 0.5
      sprite

  @print:()->
    console.log @sharePrivate

  objectState: {}
  selectedObject : {}
  layerName: {}
  objectName: ""
  frameName: ""

  constructor:()->
    super(arguments)

  setObjectName:({objectName, objectState})->
    #objectState  optional, default variable

  setObjectState:({objectState})->
    #over write current object state

  updateObjectState:({objectState})->
    @objectState = objectState;
    frameName = @getObjectState()
    @changeSprite frameName

  remove: ()->
    console.log "kiss.Node.remove: todo"

  changeSprite:(frameName)->
    #frameName = frameName.split("/").pop()
    if @frameName != frameName
      @frameName = frameName
      anchorX = @anchorX
      anchorY = @anchorY

      #@initWithSpriteFrameName @frameName
      @initWithFile @frameName
      @anchorX = anchorX
      @anchorY = anchorY

  getObjectState : ()->
    if @selectedObject and @selectedObject.layers[@layerName]?
      objectStateKey = []
      for variable in @selectedObject.layers[@layerName].variableKeys
        if @objectState[variable]?
          objectStateKey.push @objectState[variable]

      objectStateKey = objectStateKey.join()
      if @selectedObject.layers[@layerName].objectStates[objectStateKey]?
        @selectedObject.layers[@layerName].objectStates[objectStateKey]
      else
        false
    else
      false
