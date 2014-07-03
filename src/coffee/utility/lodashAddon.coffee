if global?
  require './console'
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

  _.loadObjectFile = (url, callback) ->
    req = new XMLHttpRequest()
    req.addEventListener 'readystatechange', =>
      if req.readyState is 4                        # ReadyState Compelte
        successResultCodes = [200, 304]
        if req.status in successResultCodes
          objectListFile = eval '(' + req.responseText + ')'

          if callback?
            callback objectListFile
        else
          console.log 'Error loading data...'

    req.open 'GET', url, false
    req.send()

  _.saveObjectFile = (url, object) ->
    req = new XMLHttpRequest()

    req.addEventListener 'readystatechange', =>
      if req.readyState is 4                        # ReadyState Compelte
        successResultCodes = [200, 304]
        if req.status in successResultCodes

        else
          console.log 'Error loading data...'

    req.open 'POST', url, false
    req.send(JSON.stringify(object))

  _.saveObjectList = (currentTime, object)->
    newTime = new Date().getTime()
    newFile = 
      time: newTime
      object: object

    @loadObjectFile 'src/php/resourceManager/objectLoad.php', (file)=>
      if currentTime isnt file.time
        if confirm('You are not a newest version. Are you really want to save?')
          @saveObjectFile('src/php/resourceManager/objectSave.php', newFile)
          @saveObjectFile('src/php/resourceManager/saveGameData.php', object)
        else 
          newTime = currentTime
      else
        @saveObjectFile('src/php/resourceManager/objectSave.php', newFile)
        @saveObjectFile('src/php/resourceManager/saveGameData.php', object)

    newTime