class ResourceManager 
  constructor:({@app}={})->
    @bindEvent = {}
    @objectList = {}
    @form = {}
    if window?
      @_bootAngularJs();
    @loadObject();

  _bootAngularJs:()->
    boot = false
    if not @app?
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

  on: ({event, method})->
    if not @bindEvent[event]?
      @bindEvent[event] = []
    @bindEvent[event].push method

  trigger: ({event, parameters})->
    if @bindEvent[event]?
      for method in @bindEvent[event]
        method @, parameters

  addObject: ({objectName}={})=>
    objectName ?= @form.objectName
    if objectName and not @objectList[objectName]?
      @selectedObject = @objectList[objectName] = 
        variables       : {}
        variableDefault : {}
        animations      : {}
        layers          : {}
      @form.objectName = ""
      @selectedVariable = false
      @selectedAnimation = false
      @loadResource()
      @trigger 
        event:"addObject" 
        parameters:[objectName]


  deleteObject: ({objectName})->
    if @selectedObject == @objectList[objectName]
      @selectedObject = false
      @selectedVariable = false
      @selectedVariableName = false
    delete @objectList[objectName]
    @trigger 
      event:"deleteObject" 
      parameters:[objectName]


  selectObject: ({objectName})->
    @selectedObject = @objectList[objectName]
    @selectedVariable = false
    @selectedVariableName = false
    @selectedLayer = false
    if @objectRename isnt objectName
      delete @objectRename

    delete @dragVariableName
    @loadResource()
    @trigger 
      event:"selectObject" 
      parameters:[objectName]


  addAnimation: ({animationName}={})->
    animationName ?= @form.animationName
    
    if animationName not in @selectedObject.animations?
      @selectedObject.animations[animationName] = []
      @form.animationName = ""
      @selectAnimation
        animationName: animationName
      @trigger 
        event:"addAnimation" 
        parameters:[animationName]


  deleteAnimation: ({animationName})->
    if @selectedObject.animations[animationName]?
      delete @selectedObject.animations[animationName]
      @trigger 
        event:"deleteAnimation" 
        parameters:[animationName]


  selectAnimation: ({animationName})->
    if @selectedObject.animations[animationName]?
      @selectedAnimation = animationName
      @trigger 
        event:"selectAnimation" 
        parameters:[animationName]

    if @animationRename isnt animationName
      delete @animationRename


  addLayer: ({layerName}={})->
    layerName ?= @form.layerName

    if layerName and not @selectedObject.layers[layerName]?
      @selectedObject.layers[layerName] = {variableKeys: [], objectStates: {"":false}}
      @selectedLayer = @selectedObject.layers[layerName]
      @form.layerName = ""
      @trigger 
        event:"addLayer" 
        parameters:[layerName]


  deleteLayer: ({layerName})->
    if @selectedObject.layers[layerName]?
      @selectedLayer = false
      delete @selectedObject.layers[layerName]
      @trigger 
        event:"deleteLayer" 
        parameters:[layerName]


  selectLayer: ({layerName})->
    if @selectedObject.layers[layerName]?
      @selectedLayer = @selectedObject.layers[layerName]
      @trigger 
        event:"selectLayer" 
        parameters:[layerName]

    if @layerRename isnt layerName
      delete @layerRename


  deleteLayerVariable: ({layerName, variableName})->
    layer = @selectedObject.layers[layerName]
    variableIndex = layer.variableKeys.indexOf variableName
    
    if variableIndex isnt -1
      @_objectStatesDeleteVariable
        layer: layer
        variableDefault: @selectedObject.variableDefault[variableName]
        variableName: variableName

      spliceIndex = layer.variableKeys.indexOf(variableName)
      layer.variableKeys.splice spliceIndex, 1


  addVariable: ({variableName, variableDefault}={})->
    variableName ?= @form.variableName
    variableDefault ?= @form.variableDefault

    if variableName and variableDefault and 
        not @selectedObject.variables[variableName]?
      @selectedObject.variables[variableName] = []
      @selectVariable
        variableName: variableName

      @selectedObject.variableDefault[variableName] = variableDefault
      @selectedVariable.push variableDefault
      
      @form.variableName = ""
      @form.variableDefault = ""
      @trigger 
        event:"addVariable" 
        parameters:[variableName]


  selectVariable: ({variableName})->
    @selectedVariable = @selectedObject.variables[variableName]
    @selectedVariableName = variableName
    if @variableRename isnt variableName
      delete @variableRename
    @trigger 
      event:"selectVariable" 
      parameters:[variableName]


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

    @trigger 
      event:"deleteVariable" 
      parameters:[variableName]

  addCombination: ({combinationName}={})->
    combinationName ?= @form.combinationName
    if combinationName and combinationName not in @selectedVariable
      @selectedVariable.push combinationName
      @form.combinationName = ""
      @_objectStatesNewCombination
        variableName: @selectedVariableName
        combinationName: combinationName
      @trigger 
        event:"addCombination" 
        parameters:[combinationName]

  deleteCombination: ({combinationName})->
    if combinationName in @selectedVariable
      if @selectedVariable.length == 1 
        @deleteVariable
          variableName: @selectedVariableName
      else
        @selectedVariable.splice @selectedVariable.indexOf(combinationName), 1
        @_objectStatesDeleteCombination
          variableName: @selectedVariableName
          combinationName: combinationName

        if @selectedObject.variableDefault[variableName] == combinationName
          @selectedObject.variableDefault[variableName] = @selectedObject.variables[variableName][0]
      @trigger 
        event:"deleteCombination" 
        parameters:[combinationName]

  renameCombination: ({combinationName, combinationRename})->
    if combinationName in @selectedVariable
      @_objectStatesRenameCombination
        combinationName: combinationName
        combinationRename: combinationRename

      combinationIndex = @selectedVariable.indexOf combinationName
      @selectedVariable[combinationIndex] = combinationRename

      if @selectedObject.variableDefault[@selectedVariableName] == combinationName
        @selectedObject.variableDefault[@selectedVariableName] = combinationRename

      @trigger 
        event:"renameCombination" 
        parameters:[combinationName, combinationRename]

    delete @combinationRename

  renameObject: ({objectName, objectRename})->
    if @objectList[objectName]? 
      object = @objectList[objectName]
      delete @objectList[objectName]
      @objectList[objectRename] = object
      @trigger 
        event:"renameObject" 
        parameters:[objectName, objectRename]

    delete @objectRename

  renameLayer: ({layerName, layerRename})->
    if @selectedObject.layers[layerName]? 
      layer = @selectedObject.layers[layerName]
      delete @selectedObject.layers[layerName]
      @selectedObject.layers[layerRename] = layer
      @trigger 
        event:"renameLayer" 
        parameters:[layerName, layerRename]

    delete @objectRename

  renameVariable: ({variableName, variableRename})->
    if @selectedObject.variables[variableName]?
      variableDefault = @selectedObject.variableDefault[variableName]

      for layerName of @selectedObject.layers
        layer = @selectedObject.layers[layerName]
        variableIndex = layer.variableKeys.indexOf variableName
        layer.variableKeys[variableIndex] = variableRename

      @selectedObject.variableDefault[variableRename] = variableDefault
      delete @selectedObject.variableDefault[variableName]

      variable = @selectedObject.variables[variableName]
      delete @selectedObject.variables[variableName]
      @selectedObject.variables[variableRename] = variable

      if @selectedVariableName == variableName
        @selectedVariableName = variableRename
      @trigger 
        event:"renameVariable" 
        parameters:[variableName, variableRename]

    delete @variableRename

  renameAnimation: ({animationName, animationRename})->
    if @selectedObject.animations[animationName]?
      animation = @selectedObject.animations[animationName]
      delete @selectedObject.animations[animationName]
      @selectedObject.animations[animationRename] = animation
      @trigger 
        event:"renameVariable" 
        parameters:[animationName, animationRename]

    delete @animationRename

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
    previous = layer.objectStates
    objectStates = {}
    variableIndex = layer.variableKeys.indexOf variableName
    for key, value of previous
      key = key.split(",")
      if key[variableIndex] == variableDefault 
        key.splice variableIndex, 1
        key = key.join(",")
        objectStates[key] = value
    layer.objectStates = objectStates

  _objectStatesRenameCombination: ({combinationName, combinationRename})->
    if combinationName in @selectedVariable
      combinationIndex = @selectedVariable.indexOf combinationName


      for layerName of @selectedObject.layers
        layer = @selectedObject.layers[layerName]
        variableIndex = layer.variableKeys.indexOf @selectedVariableName

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
      objectStates = layer.objectStates
      variableIndex = layer.variableKeys.indexOf variableName

      for key, value of layer.objectStates
        key = key.split(",")
        key[variableIndex] = combinationName
        objectStates[key] = false

  _objectStatesDeleteCombination: ({variableName, combinationName})->
    for layerName of @selectedObject.layers
      layer = @selectedObject.layers[layerName]
      objectStates = layer.objectStates
      variableIndex = layer.variableKeys.indexOf variableName

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
    @trigger 
      event:"activeObjectRename" 
      parameters:[objectName]

  activeLayerRename:({layerName})->
    @layerRename = layerName
    @trigger 
      event:"activeLayerRename" 
      parameters:[layerName]

  activeVariableRename:({variableName})->
    @variableRename = variableName
    @trigger 
      event:"activeVariableRename" 
      parameters:[variableName]

  activeCombinationRename:({combinationName})->
    @combinationRename = combinationName
    @trigger 
      event:"activeCombinationRename" 
      parameters:[combinationName]

  activeAnimationRename:({animationName})->
    @animationRename = animationName
    @trigger 
      event:"activeAnimationRename" 
      parameters:[animationName]

  getFilename:(path)->
    path.split('/').pop().split('.').shift();

  dropResourceName:({objectState})->
    if @dragResourceName? 
      @selectedLayer.objectStates[objectState] = @dragResourceName
      delete @dragResourceName

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
    delete @dragResourceName


  loadResource: ->
    if not @resourceList?
      req = new XMLHttpRequest()
   
      req.addEventListener 'readystatechange', =>
        if req.readyState is 4                        # ReadyState Compelte
          successResultCodes = [200, 304]
          if req.status in successResultCodes
            data = CoffeeScript.eval '(' + req.responseText + ')'
            @resourceList = data
          else
            console.log 'Error loading data...'

      req.open 'GET', 'src/php/resourceManager/resources.php', false
      req.send()
      @trigger 
        event:"loadResource"
        parameters:[]

  saveObject: ->
    req = new XMLHttpRequest()

    req.addEventListener 'readystatechange', =>
      if req.readyState is 4                        # ReadyState Compelte
        successResultCodes = [200, 304]
        if req.status in successResultCodes

        else
          console.log 'Error loading data...'

    req.open 'POST', 'src/php/resourceManager/objectSave.php', false
    req.send(@ObjectToCoffee(@objectList))
    @trigger 
      event:"saveObject"
      parameters:[]

  loadObject: ->
    req = new XMLHttpRequest()

    req.addEventListener 'readystatechange', =>
      if req.readyState is 4                        # ReadyState Compelte
        successResultCodes = [200, 304]
        if req.status in successResultCodes
          data = CoffeeScript.eval '(' + req.responseText + ')'
          @objectList = data

          for key, value of data
            break
          @selectObject objectName:key
          @_scopeApply()
        else
          console.log 'Error loading data...'

    req.open 'GET', 'src/php/resourceManager/objectLoad.php', false
    req.send()
    @trigger 
      event:"loadObject"
      parameters:[]

  _scopeApply: ()->
    if @scope?
      phase = @scope.$root.$$phase;
      if not (phase == '$apply' || phase == '$digest')
        @scope.$apply()


  ObjectToCoffee : (object, indent = "", space="  ")->
    result = []
    switch @typeOf object
      when "array"
        if object.length == 0
          result.push  indent + "[]"
        else
          result.push  indent + "["
          for value in object
            result.push @ObjectToCoffee value, indent + space
          result.push  indent + "]"
      when "object"
        result.push indent + "{"
        for key, value of object
          v =  @ObjectToCoffee value, indent + space
          result.push  indent + space + "\"#{key}\" : " + v.trim()
        result.push  indent + "}"
      when "boolean", "number"
        result.push indent + " " + object
      else
        result.push indent + "\"#{object}\""
    result.join  "\n"


  typeOf : ( value ) ->
    if value and
        typeof value is 'object' and
        value instanceof Array and
        typeof value.length is 'number' and
        typeof value.splice is 'function' and
        not ( value.propertyIsEnumerable 'length' )
      return "array"
    typeof value



if window?
  if window.resourceManager
    window.om = new ResourceManager(); 
  else
    window.ResourceManager = ResourceManager

###

om.addObject 
  objectName:"gem"

om.addVariable 
  variableName: "color"
  variableDefault: "red"

om.addCombination
  combinationName: "blue"


#Issue cant rename yet.

om.addObject 
  objectName:"gem"

om.addVariable 
  variableName: "color"
  variableDefault: "red"

om.addCombination
  combinationName: "blue"

om.addVariable 
  variableName: "snap"
  variableDefault: "off"

om.renameCombination
  combinationName: "off"
  combinationRename: "on"

#om.deleteCombination
#  combinationName: "on"

om.selectVariable 
  variableName: "color"

#om.deleteCombination
#  combinationName: "red"

#om.deleteCombination
#  combinationName: "blue"
###













































###
om.addObject 
  objectName:"gem"

om.addVariable 
  variableName: "color"
  variableDefault: "red"

om.addCombination
  combinationName: "blue"


Issue cant rename yet.
###

###
om.addObject 
  objectName:"gem"

om.addVariable 
  variableName: "color"
  variableDefault: "red"

om.addCombination
  combinationName: "blue"

om.addVariable 
  variableName: "snap"
  variableDefault: "off"

om.renameCombination
  combinationName: "off"
  combinationRename: "on"

#om.deleteCombination
#  combinationName: "on"

om.selectVariable 
  variableName: "color"

#om.deleteCombination
#  combinationName: "red"

#om.deleteCombination
#  combinationName: "blue"

console.log om.objectList
###

