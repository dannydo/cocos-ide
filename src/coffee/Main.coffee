loaded = ->
    cc.view.adjustViewPort(true);
    if cs?
      cs.pm._onchange[0]()
    else
      cc.view.setDesignResolutionSize(640, 960, cc.ResolutionPolicy.SHOW_ALL);

    cc.view.resizeWithBrowserSize(false);
    cc.LoaderScene.preload [], ->
            cc.director.runScene(new MainScene());
        , this


if CoffeeScript?
    loaded()
else
    cc.game.onStart = loaded
    cc.game.run()
