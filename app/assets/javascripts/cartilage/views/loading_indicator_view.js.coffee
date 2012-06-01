#
# Loading Indicator View
#
# Manages the display of a canvas-based spinning loading indicator.
#

class window.Cartilage.Views.LoadingIndicatorView extends Cartilage.View

  className: "loading-indicator-view"

  #
  # The canvas element where the loading indicator is drawn.
  #
  canvasElement: null

  #
  # The canvas context for the loading indicator.
  #
  canvasContext: null

  #
  # The number of bars that should be drawn in the spinner. Defaults to 10.
  #
  barCount: 10

  #
  # The width and height of the bars. Defaults to `{ width: 4, height: 12 }`.
  #
  barSize:
    width: 4
    height: 12

  #
  # The color of the bars.
  #
  barColor:
    red: 85
    green: 85
    blue: 85

  #
  # The x and y coordinates for the center point of the loading indicator
  # within the canvas. This should typically be the canvas width and height
  # divided by 2.
  #
  centerPosition:
    x: 48
    y: 48

  #
  # The inner radius of the spinning indicator. Each bar will be drawn from
  # this point, outward.
  #
  innerRadius: 10

  #
  # Whether or not the loading indicator is currently animating.
  #
  isAnimating: false

  _currentOffset: 0


  initialize: (options = {}) ->
    # TODO Set options...

    # Initialize Canvas Element
    @canvasElement = ($ "<canvas width='96' height='96'/>")[0]

    # If ExplorerCanvas is present, initialize the canvas element with it for
    # compatibility with Internet Explorer
    if typeof G_vmlCanvasManager != "undefined"
      G_vmlCanvasManager.initElement(@canvasElement)

    # Initialize Canvas Context
    @canvasContext = @canvasElement.getContext("2d")

  render: ->
    ($ @el).html @canvasElement


    #     var color = this.get("element").getStyle("color");
    #     if (color)
    #     {
    #       colors = color.split(',');
    #       red    = parseInt(colors[0].substr(4, 3), 10);
    #       green  = parseInt(colors[1], 10);
    #       blue   = parseInt(colors[2], 10);
    #       this.barColor = { red: red, green: green, blue: blue };
    #     }
    #     else this.barColor = { red: 85, green: 85, blue: 85 };
    # @start()
    @


  #
  # Starts the loading indicator animation.
  #
  start: ->
    return if @isAnimating
    @isAnimating = true
    @_animateNextFrame()
    @isAnimating

  #
  # Stops drawing the loading indicator and clears its context state.
  #
  stop: ->
    return unless @isAnimating
    @_clearFrame(@canvasContext)
    @isAnimating = false

  remove: =>
    @stop() and super()

  #
  # Draw a frame.
  #
  _draw: (context, offset) ->
    @_clearFrame(context)
    context.save()
    context.translate(@centerPosition.x, @centerPosition.y)

    for i in [0..@barCount]
      currentBar = (offset + i) % @barCount
      pos        = @_calculatePosition(currentBar)

      context.save()
      context.translate(pos.x, pos.y)
      context.rotate(pos.angle)

      @_drawBlock(@canvasContext, i)

      context.restore()

    context.restore()

  _drawBlock: (context, barNumber) ->
    context.fillStyle = @._makeRGBA(@barColor.red, @barColor.green, @barColor.blue, (@barCount + 1 - barNumber) / (@barCount + 1))
    context.fillRect(-@barSize.width / 2, 0, @barSize.width, @barSize.height)

  _animateNextFrame: =>
    return unless @isAnimating
    @_currentOffset = (@_currentOffset + 1) % @barCount
    @_draw(@canvasContext, @_currentOffset)
    _.delay @_animateNextFrame, 50

  _clearFrame: (context) ->
    context.clearRect(0, 0, @canvasElement.clientWidth, @canvasElement.clientHeight)

  _calculateAngle: (barNumber) ->
    2 * barNumber * Math.PI / @barCount

  _calculatePosition: (barNumber) ->
    angle = @_calculateAngle(barNumber)
    {
      y: (@innerRadius * Math.cos(-angle)),
      x: (@innerRadius * Math.sin(-angle)),
      angle: angle
    }


  _makeRGBA: ->
    "rgba(#{arguments[0]}, #{arguments[1]}, #{arguments[2]}, #{arguments[3]})"
