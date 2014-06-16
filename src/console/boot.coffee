if global?
  global.root = global
  root.kiss = root.kiss ? {}

  if root.nodeMode? and __filename == process.argv[1]
    console.log "console test code goes here"
  else
    root.cc = 
      ActionInterval : {}
      Sprite : {}

    libraryPath = "./../../library"

    root.nodeMode = true
    root._ = require "#{libraryPath}/lodash.js"
    require "./../coffee/utility/lodashAddon.coffee"
    require "./../coffee/models/tween.coffee"
    require "./../coffee/models/action.coffee"
    require "./../coffee/models/node.coffee"
    require "./../coffee/models/kiss.coffee"
    require "./../html/resourceManager.coffee"
