class ci.Knob
  @_selected: []
  @_index: {}
  @_list: []
  @_initialized = false

  @removeAllKnob: ()->
    for knob in _.clone @_list
      knob.remove()

  @createKnob: ({position})->
    index = @_positionIndex position
    if position.row >= 0 and position.col >= 0 and not @_index[index]?
      knob = new Knob position
      @layer.addChild knob.draw
      @_index[knob.index] = knob
      @_list.push knob
      knob

  @_hoverFrameSelected: (event)=>
    @_clearSelection()
    for knob in @_list
      if knob.col == event.originalEvent.col
        knob.select() 

  @_initialize:({@parent, @layer})->
    @_initialized = true

    #@parent._segmentLayer.bind "hover-frame-selected", @_hoverFrameSelected

    @parent.draw.bind "dblclick", (event)=>
      position = @_eventPosition event
      knob = @createKnob 
        position: position
      if knob?
        @_triggerKnobAdded
          knob: knob
        @_triggerUpdate()

    @_selectionBox = @parent.ocanvas.display.rectangle
      x: 0
      y: 0
      origin: @parent.zeroOrigin
      width: 0
      height: 0
      fill: "rgba(255, 0, 255, 0.05)"
      stroke: "1px #f0f"

    @parent.draw.bind "mousemove", (event)=>
      if @selection?
        mousemove = @_eventPosition event
        previous = @selection.mousemove

        {mousedown} = @selection
        {min, max} = @_boudingPosition mousedown, mousemove

        @_selectionBox.x = min.col * @parent.size.x + @parent.offset.x / 2
        @_selectionBox.y = min.row * @parent.size.y + @parent.offset.y / 1.5
        @_selectionBox.width = (max.col - min.col + 1) * @parent.size.x 
        @_selectionBox.height = (max.row - min.row + 1) * @parent.size.y
        @_selectionBox.redraw()

        if mousemove.row != previous.row or 
            mousemove.col != previous.col

          @selection.mousemove = mousemove

          Knob._clearSelection()

          for knob in @_list
            if min.row <= knob.row <= max.row and
                 min.col <= knob.col <= max.col
               knob.select()

    @parent.draw.bind "mousedown", (event)=>
      @_clearSelection()
      
      mousedown = @_eventPosition event

      @selection =
        mousedown: mousedown
        mousemove: mousedown

      @_selectionBox.x = 0
      @_selectionBox.y = 0
      @_selectionBox.width = 1
      @_selectionBox.height = 1
      @layer.addChild @_selectionBox

    @parent.draw.bind "mouseup", (event)=>
      if @selection?
        delete @selection
      @_selectionBox.remove()


  @_eventPosition:(event)->
    col : Math.round (event.x - @parent.offset.x) / @parent.size.x
    row : Math.round (event.y - @parent.offset.y) / @parent.size.y

  @_boudingPosition:(positionA, positionB)->
    min:
      col: Math.min(positionA.col, positionB.col)
      row: Math.min(positionA.row, positionB.row)
    max:
      col: Math.max(positionA.col, positionB.col)
      row: Math.max(positionA.row, positionB.row)

  @_clearSelection: ()->
    for knob in Knob._list
      knob._displayNormal()
      knob._displayStrokeNormal()
    Knob._selected = []

  @_triggerUpdate:()->
    @layer.trigger "knob-update", {manager:@}

  @_triggerDelete:({knobs})->
    @layer.trigger "knob-delete", {deleted:knobs, manager:@}

  @_triggerKnobAdded:({knob})->
    @layer.trigger "knob-added", {added:knob, manager:@}

  @_triggerKnobSelected:()->
    @layer.trigger "knob-selected", {selected:@_selected, manager:@}

  @_positionIndex:({row, col})->
    "#{col}:#{row}"


  constructor: ({@col, @row})->
    parent = Knob.parent

    @draw = parent.ocanvas.display.polygon
      x: parent.size.x * @col + parent.offset.x
      y: parent.size.y * @row + parent.offset.y
      origin: { x: 0, y: 0 }
      sides: 4
      radius: parent.size.x/2
      rotation: 90

    @index = Knob._positionIndex 
      row: @row 
      col: @col

    @_bind()
    @select()
    @_displayStrokeNormal()

  _translate:(col)->
    if @col != col
      @col = col
      delete Knob._index[@index]
      @index = Knob._positionIndex 
        row: @row
        col: @col
      Knob._index[@index] = @
      @draw.x = Knob.parent.size.x * (@col + 1)

  _bind:()->
    @draw.bind "mouseenter", (event)=>
      @_displayStrokeHover()

    @draw.bind "mouseleave", (event)=>
      @_displayStrokeNormal()

    @draw.bind "mousedown", @_mouseDown

    @draw.bind "dblclick", (event)=>
      knobs = _.clone Knob._selected
      for knob in Knob._selected
        knob.remove()
      Knob._clearSelection()
      Knob._triggerDelete(knobs:knobs)
      event.stopPropagation()

  _mouseMove:(event)=>
    position = Knob._eventPosition(event)
    delta = position.col - @mouse.position.col
    if delta != 0

      min_col = 0
      invalidMove = false
      for knob in Knob._selected
        min_col = Math.min(min_col, knob.col + delta) 
        index = Knob._positionIndex 
          col: knob.col + delta
          row: knob.row

        if Knob._index[index]? and not Knob._index[index]._selected
          invalidMove = true 

      if not invalidMove
        if min_col < 0
          delta -= min_col
          position.col -= min_col

        @mouse.position = position
        if delta
          for knob in Knob._selected
            knob._translate(knob.col + delta)
          Knob._triggerUpdate()
          @draw.redraw()

  _mouseUp:(event)=>
    Knob.parent.draw.unbind "mousemove", @_mouseMove
    Knob.parent.draw.unbind "mouseup", @_mouseUp
    delete @mouse

  _mouseDown:(event)=>
    @_mouseUp() #prevent possible future issue
    Knob.parent.draw.bind "mousemove", @_mouseMove
    Knob.parent.draw.bind "mouseup", @_mouseUp

    @mouse =
      position: Knob._eventPosition(event)
    event.stopPropagation()

    if not @_selected
      Knob._clearSelection()
      @select()

  remove:()->
    @draw.remove(false)
    delete Knob._index[@index]
    _.pull Knob._list, @

  select:()->
    if @ not in Knob._selected
      Knob._selected.push @
      Knob._triggerKnobSelected(Knob._selected)
    @_displayHighlight()

  _displayHighlight:()->
    @draw.fill = "rgb(255,0,255)"
    @_selected = true

  _displayNormal:()->
    @draw.fill = "#333"
    @_selected = false

  _displayStrokeHover:()->
    @draw.stroke = "1px rgb(255,0,255)"
    @draw.redraw()

  _displayStrokeNormal:()->
    @draw.stroke = "1px #fff"
    @draw.redraw()
