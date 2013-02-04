
class Bar
  ...

  initialize: (barMaxHeight, barWidth) =>
    # Set scaleY to 0 to make them 'grow', by animating this property
    _front.scaleY = 0

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

  animate: ->
    createjs.Tween.get(_front)
      .wait(@barNumber*200+500)
      .to({scaleY:1},1200)
    return @
