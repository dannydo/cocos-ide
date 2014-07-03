class kiss.Property
  constructor: ({@bindingName})->
    @_bind()
    @_dataProperties = {}
    @_activeDragProperty()

  _bind:()->
    $("input[id^=property]").on "change", ()=>
      @_onChange()

    if @bindingName?
      kiss.event.on
        channel: "borderNode.setProperties"
        method: (dataProperties)=>
          @_dataProperties = dataProperties
          @_setProperties()

      kiss.event.on
        channel: "borderNode.updatePropertyPosition"
        method: (position)=>
          @_dataProperties.position.x = position.x
          @_dataProperties.position.y = position.y
          @_setProperties()

      kiss.event.on
        channel: "objectList.onSelectObject"
        method: (objectList)=>
          @_generateHtmlObjectList(objectList)

      kiss.event.on
        channel: "borderNode.onScale"
        method: (scale) =>
          @_dataProperties.scale.x = scale.x
          @_dataProperties.scale.y = scale.y
          @_setProperties()

      kiss.event.on
        channel: "borderNode.onRotation"
        method: (rotation) =>
          @_dataProperties.rotation = rotation
          @_setProperties()

      kiss.event.on
        channel: "colorpicker.onSelectColor"
        method: (color)=>
          @_dataProperties.color.r = color.r
          @_dataProperties.color.g = color.g
          @_dataProperties.color.b = color.b
          @_setProperties()


   _setProperties:()->
    if @_dataProperties?
      $("#property-layerName").html(@_dataProperties.layerName)
      $("#property-x").val(@_dataProperties.position.x)
      $("#property-y").val(@_dataProperties.position.y)

      $("#property-skewX").val(@_dataProperties.skew.x)
      $("#property-skewY").val(@_dataProperties.skew.y)

      $("#property-scaleX").val(@_dataProperties.scale.x)
      $("#property-scaleY").val(@_dataProperties.scale.y)

      $("#property-anchorX").val(@_dataProperties.anchor.x)
      $("#property-anchorY").val(@_dataProperties.anchor.y)

      $("#property-rotation").val(@_dataProperties.rotation)
      $("#property-zIndex").val(@_dataProperties.zIndex)
      $("#property-transparency").val(@_dataProperties.transparency)
      $("#property-event").val(@_dataProperties.event)

      $("#property-visible").prop("checked", @_dataProperties.visible)
      $("#property-lock").prop("checked", @_dataProperties.lock)

      cssRGBColor = "background:rgb(" + @_dataProperties.color.r + "," + @_dataProperties.color.g + "," + @_dataProperties.color.b + ")"
      $("#property-color").attr("style", cssRGBColor)

      for key, value of @_dataProperties.objectState
        $("#variable-" + key).val(@_dataProperties.objectState[key])
      
      kiss.event.emit 
        channel: "#{@bindingName}.onSetColor"
        parameter: @_dataProperties.color
          

  _generateHtmlObjectList:(objectList)->
    @_objectState = objectList.variableDefault
    html = ""
    for key, value of objectList.variables
      html += '<div class="row">'
      html += '<div class="col-md-4">' + key + '</div>'
      html += '<div class="col-md-8"><select id="variable-' + key + '">'

      for item in value
        if item == objectList.variableDefault[key]
          html += '<option selected="selected" value="' + item + '">' + item + '</option>'
        else
          html += '<option value="' + item + '">' + item + '</option>'

      html += "</select></div></div>"
    $("#property-objectList").html(html)

    $("#property-objectList select").on "change", () =>
      @_onChangeObjectStateVariable()

  _onChange:()->
    if @_dataProperties.position?
      @_dataProperties.position.x = $("#property-x").val() * 1
      @_dataProperties.position.y = $("#property-y").val() * 1

      @_dataProperties.skew.x = $("#property-skewX").val() * 1
      @_dataProperties.skew.y = $("#property-skewY").val() * 1

      @_dataProperties.scale.x = $("#property-scaleX").val() * 1
      @_dataProperties.scale.y = $("#property-scaleY").val() * 1

      @_dataProperties.anchor.x = $("#property-anchorX").val() * 1
      @_dataProperties.anchor.y = $("#property-anchorY").val() * 1

      @_dataProperties.rotation = $("#property-rotation").val() * 1
      @_dataProperties.zIndex = $("#property-zIndex").val() * 1
      @_dataProperties.transparency = $("#property-transparency").val() * 1
      @_dataProperties.event = $("#property-event").val()

      @_dataProperties.visible = $("#property-visible").is(":checked")
      @_dataProperties.lock = $("#property-lock").is(":checked")

      kiss.event.emit 
        channel: "#{@bindingName}.onChange"
        parameter: @_dataProperties

  _onChangeObjectStateVariable: ()->
    if @_dataProperties.position? and @_dataProperties.position.x != ""
      for key, value of @_objectState
        @_objectState[key] = $("#variable-" + key).val()

      kiss.event.emit 
        channel: "#{@bindingName}.onChangeObjectStateVariable"
        parameter: @_objectState

      @_onChange()

  _activeDragProperty:()->
    $(".mouse-down-property").on "mousedown", (e)=>
      if @_dataProperties.position? and @_dataProperties.position.x != ""
        elementMe = e.toElement
        valueOld = $(elementMe).val() * 1

        processDrag = (increase)=>
          id = $(elementMe).attr("id")
          switch id
            when "property-x",        "property-y"        then $(elementMe).val((valueOld + increase).toFixed(2) * 1)
            when "property-skewX",    "property-skewY"    then $(elementMe).val((valueOld + increase/10).toFixed(2) * 1)
            when "property-scaleX",   "property-scaleY"   then $(elementMe).val((valueOld + increase/50).toFixed(2) * 1)
            when "property-anchorX",  "property-anchorY"  then $(elementMe).val((valueOld + increase/100).toFixed(2) * 1)
            when "property-rotation"                      then $(elementMe).val((valueOld + increase).toFixed(2) * 1)
            when "property-zIndex"                        then $(elementMe).val((valueOld + increase/10).toFixed() * 1)
            when "property-transparency"
              transparency = (valueOld + increase/2).toFixed(0) * 1
              if transparency > 255
                transparency = 255
              else if transparency < 0
                transparency = 0
              $(elementMe).val(transparency)

          @_onChange()
    
        mouseDrag = ({event, delta})->
          if delta.x != 0
            increase = Math.round (delta.x + ((Math.pow(delta.x, 2))) * (delta.x / Math.abs(delta.x)))/20
            processDrag(increase)

        mouseDragStop = ({event, delta})->
          kiss.event.off 
            channel: "mouseDrag"
            method: mouseDrag

          kiss.event.off 
            channel: "mouseDragStop"
            method: mouseDragStop


        kiss.event.on 
          channel: "mouseDrag"
          method: mouseDrag

        kiss.event.on 
          channel: "mouseDragStop"
          method: mouseDragStop


###
property = new kiss.Property
  bindingName: "property"

dataProperties = {
  position :
    x : 10
    y : 10
  rotation : 0
  skew :
    x : 0
    y : 0
  scale :
    x : 1
    y : 1
  anchor :
    x : 0.5
    y : 0.5
  zIndex : 0
  transparency : 255
  color :
    r : 255
    g : 0
    b : 0
  visible : true
  lock : false
}

kiss.event.emit
  channel: "property.setProperties"
  parameter: dataProperties

objectList = {
  variables : {
    color : [
      "red"
      "blue"
      "green"
      "pink"
      "orange"
      "white"
    ]
    snap : [
      "off"
      "on"
    ]
    combo : [
      "1"
      "2"
      "3"
      "0"
    ]
  }
  variableDefault : {
    color : "blue"
    snap : "off"
    combo : "2"
  }
}


kiss.event.emit
  channel: "property.onSelectObjectList"
  parameter: objectList


color = {
  r : 0
  g : 255
  b : 0
}

scale = {
  x : 2
  y : 1.5
}
###