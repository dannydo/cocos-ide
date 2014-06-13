if window?
  if not window.Studio?
    window.Studio = {}
  Studio = window.Studio
else if not Studio?
  Studio = {}


class Studio.Node extends cc.Sprite
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
