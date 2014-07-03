class window.PanelManager
  constructor: ->
    @_resizablePanels = 
      row: []
      col: []
    @_collapsablePanels = 
      row: []
      col: []
    @typeSize =
      row: "height"
      col: "innerWidth"
    @typeEvent =
      row: "clientY"
      col: "clientX"
    @typePrimary = 
      top:
        type: "row"
        direction: -1
      bottom:
        type: "row"
        direction: +1
      left:
        type: "col"
        direction: -1
      right:
        type: "col"
        direction: +1

    $(window).on "resize", => @resize()
    $("body").on "mousemove", (e)=> @mouseMove(e)
    $("body").on "mouseup", (e)=> @mouseUp(e)
    @_onchange = []

  addPanel:(collapsablePanel, resizablePanel, referencePanel, type)->

    {type, direction} = @typePrimary[type]

    if _.typeOf resizablePanel is 'object'
      resizablePanel = resizablePanel[0]
    if _.typeOf collapsablePanel is 'object'
      collapsablePanel = collapsablePanel[0]
    if _.typeOf referencePanel is 'object'
      referencePanel = referencePanel[0]

    collapsablePanel._resizablePanel = resizablePanel
    collapsablePanel._contentPanel = $(".ciContent", collapsablePanel)[0]
    collapsablePanel._direction = direction

    resizablePanel._referencePanel = referencePanel
    resizablePanel._collapsablePanel ?= 
      row: []
      col: []

    if collapsablePanel not in resizablePanel._collapsablePanel[type]
      resizablePanel._collapsablePanel[type].push collapsablePanel
    if resizablePanel not in @_resizablePanels[type]
      @_resizablePanels[type].push resizablePanel
    if collapsablePanel not in @_collapsablePanels[type]
      @_collapsablePanels[type].push collapsablePanel

    $(collapsablePanel).on "mousedown", 
      (e) => @mouseDown(e, collapsablePanel, type)

  mouseUp:(e)->
    if @_mouseDown? and @_mouseDown.click
      @collapse()
    delete @_mouseDown

  mouseMove:(e)->
    if @_mouseDown?
      {typeSize, typeEvent} = @_mouseDown
      if @_mouseDown.click 
        different = Math.abs @_mouseDown.event[typeEvent] - e[typeEvent]
        if different > 8 
          @_mouseDown.click = false
      else if not @_mouseDown.collapsablePanel.hasClass "ciCollapse"
        different = (@_mouseDown.event[typeEvent] - e[typeEvent]) * 
          @_mouseDown.direction
        if @_mouseDown.previousContentPanelSize + different < 0
          different = -@_mouseDown.previousContentPanelSize

        @_mouseDown.contentPanel[typeSize] @_mouseDown.previousContentPanelSize + different
        @_mouseDown.collapsablePanel[typeSize] @_mouseDown.previousCollapsablePanelSize + different
        @_mouseDown.resizablePanel[typeSize] @_mouseDown.previousResizablePanelSize - different
        if @_mouseDown.resizablePanel[0]._resizeCallback
          @_mouseDown.resizablePanel[0]._resizeCallback()
          
        for onchange in @_onchange
          onchange()



  mouseDown:(e, collapsablePanel, type)->
    if e.target == collapsablePanel
      contentPanel = $(collapsablePanel._contentPanel)
      resizablePanel = $(collapsablePanel._resizablePanel)
      sizeType = @typeSize[type]
      @_mouseDown =
        event: e
        type: type
        typeEvent: @typeEvent[type]
        typeSize: @typeSize[type]
        click: true
        direction: collapsablePanel._direction
        previousContentPanelSize: contentPanel[sizeType]()
        previousCollapsablePanelSize: $(collapsablePanel)[sizeType]()
        previousResizablePanelSize: resizablePanel[sizeType]()
        contentPanel: contentPanel
        collapsablePanel: $(collapsablePanel)
        resizablePanel: resizablePanel

  collapse:(collapsablePanel, type)->
    if @_mouseDown?
      {contentPanel, resizablePanel, collapsablePanel, type} = @_mouseDown
      contentPanel = contentPanel[0]
      sizeType = @typeSize[type]
      resizablePanelSize = resizablePanel[sizeType]()
      collapsablePanelSize = collapsablePanel[sizeType]()

      if collapsablePanel.hasClass "ciCollapse"
        collapsablePanel.removeClass "ciCollapse"
        resizablePanel[sizeType] resizablePanelSize - 
          contentPanel._previousSize
        collapsablePanel[sizeType] collapsablePanelSize + 
          contentPanel._previousSize
      else
        contentPanel._previousSize = $(contentPanel)[sizeType]()
        resizablePanel[sizeType] resizablePanelSize + 
          contentPanel._previousSize
        collapsablePanel[sizeType] collapsablePanelSize - 
          contentPanel._previousSize
        collapsablePanel.addClass "ciCollapse"

      for onchange in @_onchange
        onchange()

  reset:->
    for type, collapsablePanels of @_collapsablePanels
      for collapsablePanel in collapsablePanels
        $(collapsablePanel)[@typeSize[type]] $(collapsablePanel)[@typeSize[type]]()
    @resize()

  resize:->
    for type, resizablePanels of @_resizablePanels
      for resizablePanel in resizablePanels

        size = $(resizablePanel._referencePanel)[@typeSize[type]]()
        for collapsablePanel in resizablePanel._collapsablePanel[type]
          size -= $(collapsablePanel)[@typeSize[type]]()

        $(resizablePanel)[@typeSize[type]](size)
        if resizablePanel._resizeCallback
          resizablePanel._resizeCallback()
    for onchange in @_onchange
      onchange()