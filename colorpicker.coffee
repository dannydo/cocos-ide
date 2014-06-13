class Colorpicker
  constructor:()->
    @colorpickerTop = 102
    @colorpickerLeft = 496
    @colorPicker = {}
    @colorPicker.rgb ?= {r:0,g:0,b:0}
    @colorPicker.dot = {top:300,left:0}
    @colorPicker.hue = {top:300}
    @colorPicker.hsb = @RGBtoHSB @colorPicker.rgb
    @colorPicker.hex = @RGBtoHEX @colorPicker.rgb
    @colorPicker.color = @HSBtoRGB({h:@colorPicker.hsb.h,s:100,b:100})
    @activeDrag()

  setScope: (scope)->
    @scope = scope

  clamp: (min, max, val)->
    if val < min
      val = min
    if val > max
      val = max
    val

  HSBtoRGB: ({h,s,b})->
    if h == 360
      h = 0
    s /= 100.0
    b /= 100.0
    h /= 60.0
    i = Math.floor h
    f = h - i
    p = (b*(1-s)*255)
    q = (b*(1-(s*f))*255)
    t = (b*(1-(s*(1-f)))*255)
    b = (Math.floor(b*255))

    [r,g,b]= [[b,t,p],[q,b,p],[p,b,t],[p,q,b],[t,p,b],[b,p,q]][i]
    r:Math.round(r)
    g:Math.round(g)
    b:Math.round(b)

  RGBtoHSB: ({r,g,b})->
    r /= 255
    g /= 255
    b /= 255

    x = Math.min(Math.min(r, g), b)
    val = Math.max(Math.max(r, g), b)

    if x is val
      h:300
      s:0
      b:val*100
    else
      f = (r == x) ? g-b : ((g == x) ? b-r : r-g)
      i = (r == x) ? 3 : ((g == x) ? 5 : 1)
      h = Math.round((i-f/(val-x))*60)%360

      if h > 0
        h = h
      else 
        h = 0
      h:h
      s:Math.round(((val-x)/val)*100)
      b:Math.round(val*100)

  HSBtoHEX: ({h,s,b})->
    @colorPicker.rgb = @HSBtoRGB @colorPicker.hsb
    @colorPicker.hex = @RGBtoHEX @colorPicker.rgb

  RGBtoHEX: ({r,g,b})->
    r = r.toString(16)
    g = g.toString(16)
    b = b.toString(16)

    r = if r.length is 1 then "0#{r}" else r
    g = if g.length is 1 then "0#{g}" else g
    b = if b.length is 1 then "0#{b}" else b

    r + g + b
    
  updateColorPickerFromHSB: ()->
    @colorPicker.rgb = @HSBtoRGB @colorPicker.hsb
    @colorPicker.hex = @RGBtoHEX @colorPicker.rgb
    @colorPicker.color = @HSBtoRGB({h:@colorPicker.hsb.h,s:100,b:100})

  updateColorPickerFromRGB: ()->
    @colorPicker.hsb = @RGBtoHSB @colorPicker.rgb
    @colorPicker.hex = @RGBtoHEX @colorPicker.rgb
    @colorPicker.color = @HSBtoRGB({h:@colorPicker.hsb.h,s:100,b:100})

  updateColorPickerFromHEX: ()->

  colorPickerColorUpdate: (e)=>
    position = @colorpickerColor.position()
    s = Math.round (e.x - @colorpickerLeft) / @colorpickerColor.width() * 100
    b = 100 - Math.round (e.y - @colorpickerTop) / @colorpickerColor.height() * 100

    s = @clamp(0, 100, s)
    b = @clamp(0, 100, b)
    
    @colorPicker.hsb.b = b
    @colorPicker.hsb.s = s
    @updateColorPickerFromHSB()

    @colorPicker.dot.top = @clamp(0, 300, e.y - @colorpickerTop)
    @colorPicker.dot.left = @clamp(0, 300, e.x - @colorpickerLeft)
    
    @scope.$apply()

  colorPickerColorMouseup: (e)=>
    @colorPickerColorUpdate(e)
    $(window).off "mousemove", @colorPickerColorUpdate
    $(window).off "mouseup", @colorPickerColorMouseup

  colorPickerHueUpdate: (e)=>
    position = @colorpickerHue.position()
    h = 360 - Math.round (e.y - @colorpickerTop) / @colorpickerHue.height() * 360
    h = @clamp(0, 360, h)
    
    @colorPicker.hsb.h = h
    @updateColorPickerFromHSB()

    @colorPicker.hue.top = @clamp(0, 300, e.y - @colorpickerTop)

    @scope.$apply()

  colorPickerHueMouseup : (e)=>
    @colorPickerHueUpdate(e)
    $(window).off "mousemove", @colorPickerHueUpdate
    $(window).off "mouseup", @colorPickerHueMouseup
 
  activeDrag:()->
    @colorpickerHue = $(".colorpicker_hue")
    @colorpickerColor = $(".colorpicker_color")
    @colorpickerColorDot = $("div div div div", @colorpickerColor)

    @colorpickerHue.on "mousedown", (e)=>
      $(window).on "mousemove", @colorPickerHueUpdate
      $(window).on "mouseup", @colorPickerHueMouseup

    @colorpickerColor.on "mousedown", (e)=>
      $(window).on "mousemove", @colorPickerColorUpdate
      $(window).on "mouseup", @colorPickerColorMouseup


window.Colorpicker = Colorpicker