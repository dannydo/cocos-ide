class kiss.colorpicker
  constructor: ({@bindingName})->
    @color =
      rgb:
        r : 0
        g : 0
        b : 0
      hsv:
        h : 0
        s : 0
        v : 0
      hex : 'FFFFFF'
    @browsingColor = {}
    @dom = 
      review: $('#colorpicker-review') 
      output: $('#output')
      button:
        select: $('#colorpicker-select')
    @_bind()

  _bind:()->
    $('#property-color').on "click", (event)=>
      @setDefault()
      $('#colorpicker-modal').modal('show')

      @dom.button.select.on "click", (event)=>
        @selectColor()

    if @bindingName?
      kiss.event.on
        channel: "property.onSetColor"
        method: ({r,g,b})=>
          console.log 'test'
          @setColor {r:r,g:g,b:b}
          @dom.output.val("##{@color.hex}")
          @dom.review.css('background-color', "rgb(#{@color.rgb.r},#{@color.rgb.g},#{@color.rgb.b})")

  rgb2hex: ({r,g,b})->
    r = r.toString(16)
    g = g.toString(16)
    b = b.toString(16)

    r = if r.length is 1 then "0#{r}" else r
    g = if g.length is 1 then "0#{g}" else g
    b = if b.length is 1 then "0#{b}" else b

    r + g + b

  setColor:({r,g,b})->
    @color.rgb.r = r
    @color.rgb.g = g
    @color.rgb.b = b

    @color.hex = @rgb2hex(@color.rgb)
    @browsingColor = @color.rgb

  changeColor:({color})->
    @color.rgb.r = color.r
    @color.rgb.g = color.g
    @color.rgb.b = color.b

    @color.hsv.h = color.h
    @color.hsv.s = color.s
    @color.hsv.v = color.v

    @color.hex = color.hex
    @dom.review.css('background-color', "rgb(#{@color.rgb.r},#{@color.rgb.g},#{@color.rgb.b})")

  selectColor: ()->
    kiss.event.emit
      channel: "#{@bindingName}.onSelectColor"
      parameter: @color.rgb

  setDefault: () ->
    $('svg').remove()
    @cp = Raphael.colorpicker(40, 20, 300, "##{@color.hex}")
    @cp2 = Raphael.colorwheel(360, 20, 300, "##{@color.hex}")
    clr = Raphael.color("##{@color.hex}")

    dom = {}
    for element in ["output","vr","vg","vb","vh","vh2","vs","vs2","vv","vl"]
      dom[element] = $ "##{element}"

    for color in "r,g,b".split(',')
      dom["v"+color].val clr[color] 

    hsv = 
      h : Math.round(clr.h * 360) + "°";
      s : Math.round(clr.s * 100) + "%";
      v : Math.round(clr.v * 100) + "%";

    for color in "h,s,v".split(',')
      dom["v"+color].val hsv[color] 

    for color in "h,s".split(',')
      dom["v"+color+"2"].val hsv[color] 

    dom.vl.val Math.round(clr.l * 100) + "%";

    dom.output.on "keyup", (event) =>
      element = $(event.target)

      @cp.color(element.val())
      @cp2.color(element.val())

    onchange = (item)=>
      (color) =>
        dom.output.val color.replace(/^#(.)\1(.)\2(.)\3$/, "#$1$2$3");
        item.color(color);
        color = Raphael.color(color);
        dom.vr.html color.r;
        dom.vg.html color.g;
        dom.vb.html color.b;

        h = Math.round(color.h * 360) + "°"
        s = Math.round(color.s * 100) + "%"
        dom.vh.html h
        dom.vh2.html h
        dom.vs.html s
        dom.vs2.html s
        dom.vv.html Math.round(color.v * 100) + "%";
        dom.vl.html Math.round(color.l * 100) + "%";

        @changeColor {color:color}

    @cp.onchange = onchange(@cp2);
    @cp2.onchange = onchange(@cp);
    
    $('.modal-body').append($('svg'))


window.colorpicker = new kiss.colorpicker
  bindingName: "colorpicker"

kiss.event.emit
  channel: "colorpicker.onSetColor"
  parameter: {r: 247, g: 46, b: 59}