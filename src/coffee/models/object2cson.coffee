typeOf = ( value ) ->
  if value and
      typeof value is 'object' and
      value instanceof Array and
      typeof value.length is 'number' and
      typeof value.splice is 'function' and
      not ( value.propertyIsEnumerable 'length' )
    return "array"
  typeof value

ObjectToCoffee = (object, indent = "")->
  result = []
  switch typeOf object
    when "array"
      result.push  "["
      for value in object
        result.push "  " + ObjectToCoffee value, indent + "  "
      result.push  "]"
    when "object"
      result.push "{"
      for key, value of object
        result.push  indent + "#{key} : " + ObjectToCoffee value, indent + "  "
      result.push  "}"
    else
      result.push object
  result.join  "\n"+indent
