o =
  typeOf : ( value ) ->
    if value and
        typeof value is 'object' and
        value instanceof Array and
        typeof value.length is 'number' and
        typeof value.splice is 'function' and
        not ( value.propertyIsEnumerable 'length' )
      return "array"
    typeof value
  ObjectToCoffee : (object, indent = "", space=" ")->
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
          result.push  indent + "\"#{key}\" : " + v.trim()
        result.push  indent + "}"
      when "boolean", "number"
        result.push indent + " " + object
      else
        result.push indent + "\"#{object}\""
    result.join  "\n"



console.log o.ObjectToCoffee [
  a: 1
  b: [1,2,3,4]
  c: "Cong"
  d: 
    a:1
    b:2
    c: [1,2,3,4]
    d: [{
      b:{}
    }] 
]
console.log o.ObjectToCoffee 1

console.log o.typeOf 1
