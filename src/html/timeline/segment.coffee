class Segment
  @_segments = {}
  @_initialize:({@parent, @layer})->
    @_bind()

  @_bind:()->
    @parent._knobLayer.bind "knob-delete" , (event)=>
      effectedRows = []
      rows = {}

      for knob in event.originalEvent.manager._list
        if not rows[knob.row]?
          rows[knob.row] = []
        rows[knob.row].push knob

      for row, knobs of @_segments
        row *= 1
        if not rows[row]? or rows[row].length >= knobs.length
          effectedRows.push row

      @_update 
        effectedRows: effectedRows
        event: event

    @parent._knobLayer.bind "knob-update" , (event)=>
      effectedRows = []

      for knob in event.originalEvent.manager._selected
        if knob.row not in effectedRows
          effectedRows.push knob.row

      @_update 
        effectedRows: effectedRows
        event: event

  @_update: ({effectedRows, event})->
    rows = {}
    for row in effectedRows
      rows[row] = []
      
    if event.originalEvent._list
      for knob in event.originalEvent._list
        if rows[knob.row]?
          rows[knob.row].push knob

    for row, knobs  of rows
      rows[row].sort (a, b)-> a.col - b.col
      if @_segments[row]?
        if @_segments[row].length >= rows[row].length
          spliceLength = @_segments[row].length - rows[row].length + 1
          spliceIndex = @_segments.length - spliceLength
          for segment in @_segments[row].splice spliceIndex, spliceLength
            segment.remove()
      else
        @_segments[row] = []

    for row, knobs of rows
      row *= 1
      for knob, index in knobs
        if index > 0
          previous = knobs[index-1]
          paramaters =
            row: row
            col: previous.col
            range: knob.col - previous.col

          if @_segments[row][index-1]?
            @_segments[row][index-1].update paramaters
          else
            @_segments[row].push new Segment paramaters


  constructor: ({@col, @row, @range})->
    parent = Segment.parent
    @draw = parent.ocanvas.display.rectangle
      x: parent.size.x * (@col + 1)
      y: parent.size.y * (@row + 1) 
      origin: parent.zeroOrigin
      width: parent.size.x * @range
      height: parent.size.y
      fill: "rgba(255, 255, 255, 0.3)"
      stroke: "1px #fff"

    Segment.layer.addChild @draw

  update: ({@col, @row, @range})->
    parent = Segment.parent
    @draw.x = parent.size.x * (@col + 1)
    @draw.y = parent.size.y * (@row + 1) 
    @draw.width = parent.size.x * @range

  remove:()->
    @draw.remove()

ci.Segment = Segment