if global?
  require './../../console/boot.coffee'
  kiss = global.kiss
else
  root = window
  kiss = root.kiss ? {}

if kiss.Node? and __filename? and __filename == process.argv[1]
  console.log "node test goes here"
  return

class kiss.Node extends cc.Sprite
  @_recycleSpriteNode = []

  @getSpriteNode:(frameName)->
    if not @_recycleSpriteNode.length
      @_recycleSpriteNode.push new @()
    sprite = @_recycleSpriteNode.pop()
    sprite.initWithSpriteFrameName frameName
    sprite.anchorX = 0.5
    sprite.anchorY = 0.5
    sprite

  @print:()->
    console.log @sharePrivate

  remove: ()->

  changeSprite:(frameName)->
    frameName = frameName.split("/").pop()
    if @frameName != frameName
      @frameName = frameName
      @initWithSpriteFrameName @frameName
