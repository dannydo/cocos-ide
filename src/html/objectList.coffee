class kiss.objectList
  constructor: ({@bindingName})->
    @objectList            = null
    @selectedObject        = null
    @selectedObjectName    = null
    @selectedAnimation     = null
    @selectedAnimationName = null
    @dom =
      button:
        saveObject: $('#save-resouce-object')
        addAnimation: $('#resouce-animation-add')
      input:
        newAnimationName: $('#resouce-animation-new-name')
    @_bind()

  _bind:()->
    _.loadObjectFile 'src/php/resourceManager/objectLoad.php', (objectFile)=>
      @objectFileTime = objectFile.time
      @objectList = objectFile.object
      @getObjectPosition()
      @renderObject()

      @dom.button.saveObject.on "click", (event)=>
        @saveObject()

      @dom.button.addAnimation.on "click", (event)=>
        @addAnimation {animationName: @dom.input.newAnimationName.val()}

      @dom.input.newAnimationName.on "keypress", (event)=>
        if event.keyCode is 13
          @addAnimation {animationName: @dom.input.newAnimationName.val()}

      if @bindingName?
        kiss.event.on
          channel: "property.onSetProperties"
          method: (dataProperties)=>

  activeManageObject:()->
    $('div[id^=object]').on "click", (event)=>
      element     = $(event.target)
      elementId   = element.attr('id')
      unless elementId?
        element   = element.parent()
        elementId = element.attr('id')
      objectName  = elementId.split('-')[1]
      @selectObject({objectName: objectName})

    $('div[id^=object]').on "dblclick", (event)=>
      $('div[id^=object]').find('span').show()
      $('div[id^=object]').find('input').hide()

      element     = $(event.target)
      elementId   = element.attr('id')
      unless elementId?
        element   = element.parent()
        elementId = element.attr('id')
      objectName  = elementId.split('-')[1]
      if element.find('span').is(":visible")?
        element.find('span').hide()
        element.find('input').show()

    $('div[id^=object] input').on "keypress", (event)=>
      if event.keyCode is 13
        element          = $(event.target)
        objectElementId  = element.parent().attr('id')
        objectName       = objectElementId.split('-')[1]
        renameObjectName = element.val()

        if renameObjectName
          if objectName isnt renameObjectName
            oldObject   = @objectList[objectName]
            oldPosition = @objectListPosition.indexOf objectName
            delete @objectList[objectName]

            newObjectList = {}
            for objectName, position in @objectListPosition
              if position is oldPosition
                newObjectList[renameObjectName] = oldObject
              else
                newObjectList[objectName] = @objectList[objectName]

            @objectList = newObjectList
            @selectObject({objectName: renameObjectName})

          @renderObject()
          @getObjectPosition()

  activeManageAnimation:()->
    $('div[id^=animation]').on "click", (event)=>
      element       = $(event.target)
      elementId     = element.attr('id')
      unless elementId?
        element     = element.parent()
        elementId   = element.attr('id')
      animationName = elementId.split('-')[1]
      @selectAnimation({animationName: animationName})

    $('div[id^=animation]').on "dblclick", (event)=>
      $('div[id^=animation]').find('span').show()
      $('div[id^=animation]').find('input').hide()

      element       = $(event.target)
      elementId     = element.attr('id')
      unless elementId?
        element     = element.parent()
        elementId   = element.attr('id')
      animationName = elementId.split('-')[1]
      if element.find('span').is(":visible")?
        element.find('span').hide()
        element.find('input').show()

    $('div[id^=animation] input').on "keypress", (event)=>
      if event.keyCode is 13
        element             = $(event.target)
        animationElementId  = element.parent().attr('id')
        animationName       = animationElementId.split('-')[1]
        renameAnimationName = element.val()

        if renameAnimationName
          if animationName isnt renameAnimationName
            oldAnimation = @selectedObject.animations[animationName]
            oldPosition  = @animationListPosition.indexOf animationName
            delete @selectedObject.animations[animationName]

            newAnimationList = {}
            for animationName, position in @animationListPosition
              if position is oldPosition
                newAnimationList[renameAnimationName] = oldAnimation
              else
                newAnimationList[animationName] = @selectedObject.animations[animationName]

            @selectedObject.animations = newAnimationList
            @selectAnimation({animationName: renameAnimationName})

          @renderAnimation()
          @getAnimationPosition()

    $('div[id^=animation] button[value=delete]').on "click", (event)=>
      if confirm('Are you sure?')
        element             = $(event.target)
        animationElementId  = element.parent().attr('id')
        animationName       = animationElementId.split('-')[1]

        delete @selectedObject.animations[animationName]

        @renderAnimation()
        @getAnimationPosition()


  addAnimation: ({animationName}={})->
    if animationName and @selectedObject and animationName not in @selectedObject.animations?
      @selectedObject.animations[animationName] = []
      @dom.input.newAnimationName.val ""
      @selectAnimation
        animationName: animationName

      @renderAnimation()
      @getAnimationPosition()

  saveObject: ->
    console.log @objectList
    @objectFileTime = _.saveObjectList(@objectFileTime, @objectList)
  
  getObjectPosition:()->
    @objectListPosition = []
    for objectName, object of @objectList
      @objectListPosition.push objectName

  getAnimationPosition:()->
    @animationListPosition = []
    for animationName, animation of @selectedObject.animations
      @animationListPosition.push animationName

  renderObject:()->
    $('#resouce-object').html("");

    for objectName, object of @objectList
      selected = ''
      if objectName is @selectedObjectName
        selected = 'selected'
      object =  '<div id="object-' + objectName + '" class="' + selected + '">' +
                  '<span>' + objectName + '</span>' +
                  '<input style="display: none" type="text" value="' + objectName + '">' +
                '</div>'
      $('#resouce-object').append(object);

    @activeManageObject()

  renderAnimation:()->
    $('#resouce-animation').html("");
    if @selectedObject.animations
      for animationName, animation of @selectedObject.animations
        selected = ''
        if animationName is @selectedAnimationName
          selected = 'selected'
        object =  '<div id="animation-' + animationName + '" class="' + selected + '">' +
                    '<button value="delete" style="color:black;">x</button> ' +
                    '<span>' + animationName + '</span>' +
                    '<input style="display: none" type="text" value="' + animationName + '">' +
                  '</div>'
        $('#resouce-animation').append(object);

      @activeManageAnimation()

  resetObjectRename:({objectName})->
    $('div[id^=object]').find('span').show()
    $('div[id^=object]').find('input').hide()

  resetAnimationRename:({animationName})->
    $('div[id^=animation]').find('span').show()
    $('div[id^=animation]').find('input').hide()

  selectObject:({objectName})->
    $('div[id^=object]').removeClass('selected')
    $('#object-' + objectName).addClass('selected')

    @dom.button.addAnimation.show()
    @dom.input.newAnimationName.show()

    if objectName isnt @selectedObjectName
      @resetObjectRename({objectName:objectName})
      @selectedObject     = @objectList[objectName]
      @renderAnimation()
      @getAnimationPosition()
      @selectedObjectName = objectName
      
      @selectedAnimation     = null
      @selectedAnimationName = null

      kiss.event.emit 
        channel: "#{@bindingName}.onSelectObject"
        parameter: @selectedObject

  selectAnimation:({animationName})->
    $('div[id^=animation]').removeClass('selected')
    $('#animation-' + animationName).addClass('selected')

    if animationName isnt @selectedAnimationName
      @resetAnimationRename({animationName:animationName})
      @selectedAnimation     = @selectedObject.animations[animationName]
      @selectedAnimationName = animationName

      kiss.event.emit 
        channel: "#{@bindingName}.onSelectAnimation"
        parameter: @selectedAnimation


window.objectList = new kiss.objectList
  bindingName: "objectList"