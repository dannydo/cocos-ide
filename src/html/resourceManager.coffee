
class kiss.ResourceManager 
  constructor:({@app, @bindingName}={})->
    @objectFileTime = 0
    @bindEvent      = {}
    @objectList     = {}
    @objectBackup   = {}
    @resouceMode    = 'graphics'
    @selectedGroup  = ''
    @form = {}
    if window?
      @_bootAngularJs();

  _bootAngularJs:()->
    boot = false
    if not @app? and angular?
      @app = angular.module 'CocosStudio', []
      boot = true

    if @app?
      @app.directive 'ngEnter', =>
        return  (scope, element, attrs) =>
          element.bind "keydown keypress", (event) =>
            if event.which is 13
              scope.$apply =>
                scope.$eval(attrs.ngEnter, {$event: event});
              event.preventDefault();

      @app.directive 'documentClick', =>
        return (scope, element, attrs) =>
          element.bind "click", (event) =>
            scope.$apply =>
              scope.$eval(attrs.documentClick, {$event: event});
            event.preventDefault();

    if boot
      @app.controller 'ResourceManager', ['$scope', ($scope) => @scope = $scope; return @]
      angular.element(document).ready ->
        angular.bootstrap($(".ResourceManager")[0], ['CocosStudio']);

  selectGraphichGroup: (group)->
    @selectedGroup = group

  addObject: ({objectName}={})=>
    objectName ?= @form.objectName
    if objectName and not @objectList[objectName]?
      @selectedObject = @objectList[objectName] = 
        variables       : {}
        variableDefault : {}
        sounds          : {}
        animations      : {}
        layers          : {}
        layers          : {}
      @form.objectName = ""
      @selectedVariable = false
      @selectedLayer = false
      @loadResource()
  


  deleteObject: ({objectName})->
    if @selectedObject == @objectList[objectName]
      @selectedObject = false
      @selectedVariable = false
      @selectedVariableName = false
    delete @objectList[objectName]

  selectObject: ({objectName})->
    @selectedObject = @objectList[objectName]
    @selectedVariable = false
    @selectedVariableName = false
    @selectedLayer = false
    if @objectRename isnt objectName
      delete @objectRename

    delete @dragVariableName
    @loadResource()


  addSound: ({soundNameField}={})=>
    soundName = soundNameField.value
    soundNameField.value = ''

    if @selectedObject.sounds and Object.keys(@selectedObject.sounds).length is 0
      delete @selectedObject.sounds

    @selectedObject.sounds ?= {}
    if soundName not in @selectedObject.sounds?
      @selectedObject.sounds[soundName] = false

  deleteSound: ({objectName, soundName})->
    @selectedObject = @objectList[objectName]
    delete @selectedObject.sounds[soundName]


  addLayer: ({layerName}={})->
    layerName ?= @form.layerName

    if @selectedObject.layers and Object.keys(@selectedObject.layers).length is 0
      delete @selectedObject.layers

    @selectedObject.layers ?= {}

    if layerName and not @selectedObject.layers[layerName]?
      @selectedObject.layers[layerName] = {variableKeys: [], objectStates: {"":false}}
      @selectedLayer = @selectedObject.layers[layerName]
      @form.layerName = ""
  


  deleteLayer: ({layerName})->
    if @selectedObject.layers[layerName]?
      @selectedLayer = false
      delete @selectedObject.layers[layerName]
      @deleteAnimation {layerName: layerName}
  
  deleteAnimation: ({layerName})->
    for animationName, animation of @selectedObject.animations
      for index, action of animation.splice 0, animation.length 
        if action.tag isnt layerName
          animation.push action


  selectLayer: ({layerName})->
    if @selectedObject.layers[layerName]?
      @selectedLayer = @selectedObject.layers[layerName]
  

    if @layerRename isnt layerName
      delete @layerRename


  deleteLayerVariable: ({layerName, variableName})->
    layer = @selectedObject.layers[layerName]
    variableIndex = @_getObjectIndexByValue(layer.variableKeys, variableName)
    
    if variableIndex isnt false
      @_objectStatesDeleteVariable
        layer: layer
        variableDefault: @selectedObject.variableDefault[variableName]
        variableName: variableName

      spliceIndex = @_getObjectIndexByValue(layer.variableKeys, variableName)
      layer.variableKeys.splice spliceIndex, 1


  addVariable: ({variableName, variableDefault}={})->
    variableName ?= @form.variableName
    variableDefault ?= @form.variableDefault

    if @selectedObject.variables and Object.keys(@selectedObject.variables).length is 0
      delete @selectedObject.variables

    @selectedObject.variables ?= {}

    if variableName and variableDefault and 
        not @selectedObject.variables[variableName]?
      @selectedObject.variables[variableName] = []
      @selectVariable
        variableName: variableName

      @selectedObject.variableDefault[variableName] = variableDefault
      @selectedVariable.push variableDefault
      
      @form.variableName = ""
      @form.variableDefault = ""
  


  selectVariable: ({variableName})->
    @selectedVariable = @selectedObject.variables[variableName]
    @selectedVariableName = variableName
    if @variableRename isnt variableName
      delete @variableRename


  deleteVariable: ({variableName})->
    if @selectedVariable == @selectedObject.variables[variableName]
      @selectedVariable = false
      @selectedVariableName = false

    for layerName of @selectedObject.layers
      @deleteLayerVariable
        layerName: layerName
        variableName: variableName

    delete @selectedObject.variables[variableName]
    delete @selectedObject.variableDefault[variableName]
    delete @dragVariableName


  setVariableLock: ({variableName, isLock})->
    @selectedObject.variableLock ?= {}
    @selectedObject.variableLock[variableName] = isLock

  isVariableLock: ({variableName})->
    if variableName
      if @selectedObject.variableLock
        if @selectedObject.variableLock[variableName]
          @selectedObject.variableLock[variableName]
        else 
          false
      else 
        false
    else 
      false


  setLayerHidden: ({layerName, isHidden})->
    if @selectedObject.layerHidden and Object.keys(@selectedObject.layerHidden).length is 0
      delete @selectedObject.layerHidden

    @selectedObject.layerHidden ?= {}
    @selectedObject.layerHidden[layerName] = isHidden

  isLayerHidden: ({layerName})->
    if layerName
      if @selectedObject.layerHidden
        if @selectedObject.layerHidden[layerName]
          @selectedObject.layerHidden[layerName]
        else 
          false
      else 
        false
    else 
      false


  setVariableDefault: ({variableName, combinationName})->
    if @selectedObject.variableDefault and Object.keys(@selectedObject.variableDefault).length is 0
      delete @selectedObject.variableDefault

    @selectedObject.variableDefault ?= {}
    @selectedObject.variableDefault[variableName] = combinationName


  isVariableDefault: ({variableName, combinationName})->
    if variableName and combinationName
      if @selectedObject.variableDefault[variableName]
        if @selectedObject.variableDefault[variableName] == combinationName
          true
        else
          false
      else
        false
    else
      false


  addCombination: ({combinationName}={})->
    combinationName ?= @form.combinationName
    combinationName.toString()
    
    if combinationName and not @selectedVariable[combinationName]
      @selectedVariable[combinationName] = combinationName
      @form.combinationName = ""
      @_objectStatesNewCombination
        variableName: @selectedVariableName
        combinationName: combinationName
  

  deleteCombination: ({combinationName})->
    if @selectedVariable[combinationName]
      if @selectedVariable.length == 1 
        @deleteVariable
          variableName: @selectedVariableName
      else
        delete @selectedVariable[combinationName]

        @_objectStatesDeleteCombination
          variableName: @selectedVariableName
          combinationName: combinationName

        if @selectedObject.variableDefault[@selectedVariableName] == combinationName
          @selectedObject.variableDefault[@selectedVariableName] = @selectedObject.variables[@selectedVariableName][0]
  

  renameCombination: ({combinationName, combinationRename})->
    if @selectedVariable[combinationName]
      @_objectStatesRenameCombination
        combinationName: combinationName
        combinationRename: combinationRename

      delete @selectedVariable[combinationName]
      @selectedVariable[combinationRename] = combinationRename

      if @selectedObject.variableDefault[@selectedVariableName] == combinationName
        @selectedObject.variableDefault[@selectedVariableName] = combinationRename

    delete @combinationRename

  renameObject: ({objectName, objectRename})->
    if @objectList[objectName]? 
      object = @objectList[objectName]
      delete @objectList[objectName]
      @objectList[objectRename] = object

    delete @objectRename

  renameSound: ({soundName, soundRename})->
    if @selectedObject.sounds[soundName]? 
      sound = @selectedObject.sounds[soundName]
      delete @selectedObject.sounds[soundName]
      @selectedObject.sounds[soundRename] = sound

    delete @soundRename

  renameLayer: ({layerName, layerRename})->
    if @selectedObject.layers[layerName]? 
      layer = @selectedObject.layers[layerName]
      delete @selectedObject.layers[layerName]
      @selectedObject.layers[layerRename] = layer

    delete @objectRename

  renameVariable: ({variableName, variableRename})->
    if @selectedObject.variables[variableName]?
      variableDefault = @selectedObject.variableDefault[variableName]

      for layerName of @selectedObject.layers
        layer = @selectedObject.layers[layerName]
        variableIndex = @_getObjectIndexByValue(layer.variableKeys, variableName)
        layer.variableKeys[variableIndex] = variableRename

      @selectedObject.variableDefault[variableRename] = variableDefault
      delete @selectedObject.variableDefault[variableName]

      variable = @selectedObject.variables[variableName]
      delete @selectedObject.variables[variableName]
      @selectedObject.variables[variableRename] = variable

      if @selectedVariableName == variableName
        @selectedVariableName = variableRename
  

    delete @variableRename

  _objectStatesNewVariable: ({variableName, variableDefault})->
    @selectedLayer.variableKeys.push variableName
    objectStates = {}
    for key, value of @selectedLayer.objectStates
      if key == ""
        key+="#{variableDefault}"
      else
        key+=",#{variableDefault}"
      objectStates[key] = value
    @selectedLayer.objectStates = objectStates

    for combinationIndex, combinationName of @selectedObject.variables[variableName]
      if variableDefault isnt combinationName
        @_objectStatesNewCombination
          variableName: variableName
          combinationName: combinationName

  _objectStatesDeleteVariable: ({layer, variableName, variableDefault})->
    previous      = layer.objectStates
    objectStates  = {}
    variableIndex = @_getObjectIndexByValue(layer.variableKeys, variableName)

    for key, value of previous
      key = key.split(",")
      if key[variableIndex] == variableDefault 
        key.splice variableIndex, 1
        key = key.join(",")
        objectStates[key] = value
    layer.objectStates = objectStates

  _objectStatesRenameCombination: ({combinationName, combinationRename})->
    if @selectedVariable[combinationName]
      for layerName of @selectedObject.layers
        layer         = @selectedObject.layers[layerName]
        variableIndex = @_getObjectIndexByValue(layer.variableKeys, variableName)

        objectStates = {}
        for key, value of layer.objectStates
          arrayKey = key.split(",")
          if arrayKey[variableIndex] == combinationName 
            arrayKey[variableIndex] = combinationRename
            key = arrayKey.join(",")
          objectStates[key] = value

        layer.objectStates = objectStates

  _objectStatesNewCombination: ({variableName, combinationName})->
    for layerName of @selectedObject.layers
      layer = @selectedObject.layers[layerName]
      objectStates  = layer.objectStates
      variableIndex = @_getObjectIndexByValue(layer.variableKeys, variableName)

      if variableIndex isnt false
        for key, value of layer.objectStates
          key = key.split(",")
          key[variableIndex] = combinationName
          objectStates[key] = false

  _objectStatesDeleteCombination: ({variableName, combinationName})->
    for layerName of @selectedObject.layers
      layer         = @selectedObject.layers[layerName]
      objectStates  = layer.objectStates
      variableIndex = @_getObjectIndexByValue(layer.variableKeys, variableName)

      for key, value of layer.objectStates
        key = key.split(",")
        if key[variableIndex] == combinationName
          delete objectStates[key]

  getObjectState : ({layerName, combinations})->
    if @selectedObject and @selectedObject.layers[layerName]?
      objectStateKey = []
      for variable in @selectedObject.layers[layerName].variableKeys
        if combinations[variable]?
          objectStateKey.push combinations[variable]

      objectStateKey = objectStateKey.join()
      if @selectedObject.layers[layerName].objectStates[objectStateKey]?
        @selectedObject.layers[layerName].objectStates[objectStateKey]
      else
        false
    else
      false


  activeObjectRename:({objectName})->
    @objectRename = objectName


  activeSoundRename:({soundName})->
    @soundRename = soundName


  activeLayerRename:({layerName})->
    @layerRename = layerName


  activeVariableRename:({variableName})->
    @variableRename = variableName


  activeCombinationRename:({combinationName})->
    @combinationRename = combinationName


  getFilename:(path)->
    path.split('/').pop().split('.').shift();

  getVariableNameByObjectStates:(objectStates)->
    objectStates = objectStates.toString()

    states = {}
    for key, value in objectStates.split(',')
      states[value] = key

    variables = {}
    for variableName, key of @selectedLayer.variableKeys
      variables[key] = states[variableName]

    variables

  dropGraphicName:({objectState})->
    if @dragGraphicName? 
      @selectedLayer.objectStates[objectState] = @dragGraphicName
      delete @dragGraphicName

  dropSoundFilename:({objectName, soundName})->
    if @dragSoundFilename?
      soundFilename = @getFilename @dragSoundFilename
      @objectList[objectName].sounds[soundName] = soundFilename
      delete @dragSoundFilename

  dropVariable:({layerName})->
    if @dragVariableName?
      @selectedLayer = @selectedObject.layers[layerName]

      if @dragVariableName not in @selectedLayer.variableKeys
        @_objectStatesNewVariable 
          variableName: @dragVariableName
          variableDefault: @selectedObject.variableDefault[@dragVariableName]

      delete @dragVariableName

  disableDrag:()->
    delete @dragVariableName
    delete @dragGraphicName
    delete @dragSoundFilename

  _getObjectIndexByValue:(object, checkValue)->
    key = false

    for key, value of object
      if value is checkValue
        break

    key

  changeResouceMode:(mode)->
    @resouceMode = mode

  playSound:({playSoundUrl})->
    audio = document.getElementById('audio')
    audio.setAttribute("src",playSoundUrl)
    audio.play()

  loadResource: ->
    if not @resourceList? and XMLHttpRequest?
      req = new XMLHttpRequest()
   
      req.addEventListener 'readystatechange', =>
        if req.readyState is 4                        # ReadyState Compelte
          successResultCodes = [200, 304]
          if req.status in successResultCodes
            data = CoffeeScript.eval '(' + req.responseText + ')'
            @resourceList = data

            for folder, images of @resourceList.graphics
              @selectedGroup = folder
              break;
          else
            console.log 'Error loading data...'

      req.open 'GET', 'src/php/resourceManager/resources.php', false
      req.send()

  saveObject: ->
    objectChanges = {}

    for objectName, object of @objectList
      if not _.isEqual(object, @objectBackup[objectName])
        objectChanges[objectName] = object

    for objectName, object of @objectBackup
      if not @objectList[objectName]?
        objectChanges[objectName] = {}


    @objectFileTime = _.saveObjectList(@objectFileTime, @objectList)

  loadObject: ->
    _.loadObjectFile 'src/php/resourceManager/objectLoad.php', (file)=>
      @objectFileTime = file.time
      @objectList     = file.object

      for objectName, object of @objectList
        for key, variables of object
          if key in ['variables']
            for variableName, combinations of variables
              if _.typeOf(combinations) == 'array'
                delete object[key][variableName]

                newCombinations = {}
                for combinationKey, combination of combinations
                  newCombinations[combinationKey] = combination

                @objectList[objectName][key][variableName] = newCombinations
          if key in ['layers']
            for variableName, variableValues of variables
              for variableValueKey, variableValueValues of variableValues
                if _.typeOf(variableValueValues) == 'array'
                  delete object[key][variableName][variableValueKey]

                  newValues = {}
                  for i, v of variableValueValues
                    newValues[i] = v

                  @objectList[objectName][key][variableName][variableValueKey] = newValues

      @objectBackup   = _.clone @objectList, true
      
      for key, value of @objectList
        break
      @selectObject objectName:key
      @_scopeApply()

  _scopeApply: ()->
    if @scope?
      phase = @scope.$root.$$phase;
      if not (phase == '$apply' || phase == '$digest')
        @scope.$apply()


  _fix: ()->
    for n, object of @objectList  
      for n, layer of object.layers
        for name, state of layer.objectStates
          layer.objectStates[name] = state.replace("engine/res/", "engine/res/graphics/")
          console.log state.replace("engine/res/", "engine/res/graphics/")

if window?
  resourceManager = new kiss.ResourceManager(bindingName:"resourceManager")
  resourceManager.loadObject()
  window.resourceManager = resourceManager
