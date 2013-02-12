##################################################
## Preloader class
##################################################
'use strict'
class Preloader
  constructor: (stage) ->
    @stage = stage

    # The preloader will be put into container for easier maipulation
    @container = new createjs.Container()
    @container.x = @stage.canvas.width / 2 - 65
    @container.y  = @stage.canvas.height / 2 - 20
    return @

  initialize: =>
    for i in [0...3]
      # Draw rectangles
      rect = new createjs.Shape()
      rect.graphics.beginFill("#fff").drawRect(0,0,10,10)
      rect.x = 10+i*25
      rect.y = if i==1 then 3 else 4

      # Add animation to rectangles
      createjs.Tween.get(rect)
        .wait(i*200)
      createjs.Tween.get(rect, {loop:true})
        .wait(i*300)
        .to({
          scaleY: if i==1 then 1.8    else 1.3,
          scaleX: if i==1 then 1.8    else 1.3,
          y:      if i==1 then 0      else 2,
          x:      if i==1 then 7+i*25 else 9+i*25
        },700)
        .to({
          scaleY:1,
          scaleX:1,
          y: if i==1 then 3 else 4,
          x: 10+i*25
        },600)

    # Add some simple preloader text
    preloaderText = new createjs.Text("Loading the data...", "bold 10px Arial", "#4d7a93")
    preloaderText.textAlign = "center"
    preloaderText.x = 42.5
    preloaderText.y = 22
    @container.addChild(preloaderText, rect)
    return @

  addToStage: =>
    @stage.addChild(@container)
    return @

  removeFromStage: =>
    # Some funky fade out
    createjs.Tween.get(@container).to({alpha:0}, 300).call( => @stage.removeChild(@container))
    return @

##################################################
## Bar class
##################################################

class Bar
  _front = null
  _label = null
  _desc = null
  _offset = null

  constructor: (value, desc, barNumber, offset, stage) ->
    @value = value
    @desc = desc
    @stage = stage
    @barNumber = barNumber
    _offset = offset

    @barContainer = new createjs.Container()
    @barContainer.y = @stage.height - 39
    return @

  initialize: (barMaxHeight, barWidth) =>
    # Create the front of the bar
    _front = new createjs.Shape()
    # Set scaleY to 0 to make them 'grow', by animating this property
    _front.scaleY = 0
    _front.x = @barNumber * (barWidth + _offset)
    _front.y = 0
    _front.graphics
      .beginFill('#fff')
      .drawRect(0, 0, barWidth, ~~(barMaxHeight*(@value / 100)*-1))
      .beginFill(createjs.Graphics.getHSL(180-@value*3, 100, 43))
      #color by value (0 -> red, 40 -> yellow, 80 -> green)
      .drawRect(0, ~~(barMaxHeight*(@value / 100)*-1) - 4, barWidth, 4)
      .closePath()

    # Create the label of the bar
    _label = new createjs.Text(@value + "%", "bold 10px Arial", "#033a59");
    _label.textAlign = "center";
    _label.rotation = -90
    _label.x = @barNumber * (barWidth + _offset) - 2
    _label.y = -25
    _label.alpha = 0
    # Tween it to grow with bars at initialization
    createjs.Tween.get(_label)
      .wait(@barNumber * 200 + 500)
      .to({y:(-(barMaxHeight)*(@value / 100)) - 30}, 1200)

    # Create the desc of the bar
    _desc = new createjs.Text(@desc, "bold 10px Arial", "#4d7a93")
    _desc.textAlign = "right"
    _desc.rotation = -45
    _desc.x = @barNumber * (barWidth + _offset) - 5
    _desc.y = -5
    _desc.alpha = 0
    createjs.Tween.get(_desc)
      .wait(@barNumber * 200 + 500)
      .to({alpha:1}, 1200)


    # Add children keeping order
    @barContainer.addChildAt(_front, 0)
    @barContainer.addChildAt(_label, 1)
    @barContainer.addChildAt(_desc,  2)

    # Bind hover events to display bars label
    @barContainer.onMouseOver = (e) =>
      children = e.target.children
      # Dont tween if already animated
      if(!children[1].hasActiveTweens)
        createjs.Tween.get(children[1])
          .to({alpha:1}, 400)

    @barContainer.onMouseOut = (e) =>
      label = e.target.children[1]
      createjs.Tween.get(label)
        .to({alpha:0}, 400)
    return @

  addToStage: () ->
    @stage.addChild(@barContainer)
    return @

  animate: ->
    createjs.Tween.get(_front)
      .wait(@barNumber*200+500)
      .to({scaleY:1},1200)
    return @

##################################################
## Graph class
##################################################

class Chart
  _bars = []
  _barOffset = null
  _barWidth = null

  constructor: (canvas, offset) ->
    @canvas = canvas
    @stage = new createjs.Stage(canvas)
    @stage.enableMouseOver(15)
    _barOffset = offset
    # Init preloader
    @preloader = new Preloader(@stage).initialize().addToStage()

    # Init bar conatainer
    @container = new createjs.Container()
    @container.x = 45
    @container.y = 0
    @container.height = @stage.canvas.height - 25
    @container.width = @stage.canvas.width - 45
    @stage.addChild(@container)

    # Init ticker
    createjs.Ticker.setFPS(30)
    @tickerListener = createjs.Ticker.addListener(@stage,false)

  # Download JSON data via AJAX
  loadData: (url) =>
    $.ajax({
      url: url,
      dataType: 'json',
      cache: true
    }).complete((data) => @parseData(data.responseText))

  # Parse downloaded HTML to extract the data
  parseData: (data) =>
    data = JSON.parse(data)
    for item, index in data.items
      # Populate the bar array with data
      _bars.push(new Bar(item.value, item.desc, index, _barOffset, @container))

    _barWidth = ((@container.width - ((_bars.length - 1) *_barOffset)) / _bars.length)

    # Remove preloader and draw the graph
    @preloader.removeFromStage()
    @drawBackground()
    @drawBars()

  # Draw background lines and labels
  drawBackground: ->
    for i in [0..5]
      # Create dotted lines in background
      dotLine = new createjs.Shape()
      dotLine.graphics.beginFill('#fff')
      for j in [0...100]
        x = (j / 100 * (@canvas.width)) + 35
        y = @canvas.height - ~~(((@canvas.height / 5) * (5-i)) + 65)
        dotLine.graphics.drawCircle(x,y,1)
        dotLine.graphics.closePath()

      # Create percentage on left side
      lineLabel = new createjs.Text((5-i)*25 + '%', "bold 10px Arial", "#033a59")
      lineLabel.textAlign = "right"
      lineLabel.x = 30
      lineLabel.y = @canvas.height - ~~(((@canvas.height / 5) * (5-i)) + 72)
      @stage.addChildAt(dotLine, 1)
      @stage.addChildAt(lineLabel, 1)

  drawBars: ->
    for bar, i in _bars
      bar
        .initialize(@container.height, _barWidth)
        .addToStage()
        .animate()

$(->
  new Chart($("#graph")[0], 8).loadData('json/data.json')
)