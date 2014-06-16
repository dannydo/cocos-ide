if global?
  require './../../console/boot.coffee'
  kiss = global.kiss
else
  root = window
  kiss = root.kiss ? {}

if _.clamp? and __filename? and __filename == process.argv[1]
  console.log "test code for lo-dash goes here"
else
  _.clamp = (val, min, max)->
    if val < min
      min
    else if val > max
      max
    else
      val

  _.typeOf = ( value ) ->
      if value and
          typeof value is 'object' and
          value instanceof Array and
          typeof value.length is 'number' and
          typeof value.splice is 'function' and
          not ( value.propertyIsEnumerable 'length' )
        return "array"
      typeof value


  _.objectToCoffee = (object, indent = "", space="  ")->
      result = []
      switch @typeOf object
        when "array"
          if object.length == 0
            result.push  indent + "[]"
          else
            result.push  indent + "["
            for value in object
              result.push @objectToCoffee value, indent + space
            result.push  indent + "]"
        when "object"
          result.push indent + "{"
          for key, value of object
            v =  @objectToCoffee value, indent + space
            result.push  indent + space + "\"#{key}\" : " + v.trim()
          result.push  indent + "}"
        when "boolean", "number"
          result.push indent + " " + object
        else
          result.push indent + "\"#{object}\""
      result.join  "\n"
