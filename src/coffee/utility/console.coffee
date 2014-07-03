if global?
  global.root = global
  root.kiss = root.kiss ? {}

  if root.nodeMode? and __filename == process.argv[1]
    console.log "console test code goes here"
  else
    root.cc = 
      ActionInterval : {}
      Sprite : {}

    libraryPath = "./../../../library"

    root.nodeMode = true
    root._ = require "#{libraryPath}/lodash.js"
    require "./lodashAddon.coffee"
    require "./../models/tween.coffee"
    require "./../models/action.coffee"
    require "./../models/node.coffee"
    require "./../models/kiss.coffee"
    require "./../../../resourceManager.coffee"
