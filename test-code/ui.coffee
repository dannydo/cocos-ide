root = exports ? this

class root.Ui 
  constructor:({x, y, width, height, @name})->
    @size = 
      x: 1
      y: 1
      width: 1
      height: 1
    @_resize arguments...

  _resize: ({x, y, width, height, refreshIgnore}={})->
    changed = false

    if width? and width != @size.width
      @size.width = width
      changed = true

    if height? and height != @size.height
      @size.height = height
      changed = true

    if x? and Math.round(x) != Math.round(@size.x)
      @size.x = x
      changed = true

      if Math.round(@size.x) == @size.x
        @size.x -= 0.5

    if y? and Math.round(y) != Math.round(@size.y)
      @size.y = y
      changed = true

      if Math.round(@size.y) == @size.y
        @size.y -= 0.5

    if not refreshIgnore? and changed
      @_applySizing()
      mediator.emit "#{@name}.onResize", _.clone @size

  @_applySizing:()->
