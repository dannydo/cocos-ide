class PackerImage
  constructor:()->

  packer:({resources})->
    blockImages = []
    
    count = 0;
    for key, value of resources
      width = value.boundRect.width
      height = value.boundRect.height
      #if width > height
      #  [width,height] = [height,width]
      blockImages[count] = {w: width, h:height, keyImage:key, x:value.boundRect.x, y:value.boundRect.y}
      count++

    sortPacker.now(blockImages, 'height')

    packer = new GrowingPacker()
    packer.fit(blockImages);

    jsonDataBlock = {}
    maxWidth = 0
    maxHeight = 0
    for n in [0...(blockImages.length-1)]
      blockImage = blockImages[n]
      if blockImage.fit
        jsonBlock = 
          x: blockImage.fit.x
          y: blockImage.fit.y
          w: blockImage.w
          h: blockImage.h
          minX: blockImage.x
          minY: blockImage.y

        jsonDataBlock[blockImage.keyImage] = jsonBlock

        width = jsonBlock.x + jsonBlock.w
        height = jsonBlock.y + jsonBlock.h
        if width > maxWidth
          maxWidth = width

        if height > maxHeight
          maxHeight = height

    jsonData = {}
    jsonData['size'] = {w: maxWidth, h: maxHeight}
    jsonData['blocks'] = jsonDataBlock
    jsonData

  savePacker:(dataPacker, filename) ->
    req = new XMLHttpRequest()

    req.addEventListener 'readystatechange', =>
      if req.readyState is 4                        # ReadyState Compelte
        successResultCodes = [200, 304]
        if req.status in successResultCodes

        else
          console.log 'Error loading data...'

    req.open 'POST', 'src/php/savePackerImage.php', false
    dataPost = 
        dataPacker: dataPacker
        filename: filename

    req.send(JSON.stringify(dataPost, null, 4))

kiss.PackerImage = PackerImage