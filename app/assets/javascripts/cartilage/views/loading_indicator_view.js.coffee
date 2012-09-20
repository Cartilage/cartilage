#
# Loading Indicator View
#
# Manages the display of a canvas-based spinning loading indicator.
#

class window.Cartilage.Views.LoadingIndicatorView extends Cartilage.View

  # Properties ---------------------------------------------------------------

  #
  # The number of bars that should be drawn in the spinner. Defaults to 10.
  #
  @property "barCount", default: 10

  #
  # The width and height of the bars. Defaults to `{ width: 4, height: 12 }`.
  #
  @property "barSize", default: { width: 4, height: 12 }

  #
  # The color of the bars.
  #
  @property "barColor", default: { red: 85, green: 85, blue: 85 }

  #
  # The x and y coordinates for the center point of the loading indicator
  # within the canvas. This should typically be the canvas width and height
  # divided by 2.
  #
  @property "centerPosition", default: { x: 48, y: 48 }

  #
  # The inner radius of the spinning indicator. Each bar will be drawn from
  # this point, outward.
  #
  @property "innerRadius", default: 10

  #
  # Whether or not the loading indicator is currently animating.
  #
  @property "isAnimating", access: READONLY, default: no

  # Internal Properties ------------------------------------------------------

  # --------------------------------------------------------------------------

  initialize: (options = {}) ->

    # Initialize the View
    super(options)

    # Initialize Canvas Element
    ($ @el).html @_canvasElement = @make "canvas",
      width: 96,
      height: 96

    # Initialize Canvas Context
    @_canvasContext = @_canvasElement.getContext("2d")

    # Observe for view events so that we can start or stop the indicator
    # when appropriate.
    @observe @, "willPresent", @start
    @observe @, "removed", @stop

  prepare: ->

    # Prepare the View
    super()

    # Determine the bar color from CSS, if present
    if color = ($ @el).css("color")
      colors = color.split(',')
      red    = parseInt(colors[0].substr(4, 3), 10)
      green  = parseInt(colors[1], 10)
      blue   = parseInt(colors[2], 10)
      @barColor = { red: red, green: green, blue: blue }

  #
  # Starts the loading indicator animation.
  #
  start: =>
    return if @isAnimating
    @_isAnimating = true
    @_animateNextFrame()
    @isAnimating

  #
  # Stops drawing the loading indicator and clears its context state.
  #
  stop: ->
    return unless @isAnimating
    @_clearFrame(@_canvasContext)
    @_isAnimating = false

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

      @_drawBlock(@_canvasContext, i)

      context.restore()

    context.restore()

  _drawBlock: (context, barNumber) ->
    context.fillStyle = @._makeRGBA(@barColor.red, @barColor.green, @barColor.blue, (@barCount + 1 - barNumber) / (@barCount + 1))
    context.fillRect(-@barSize.width / 2, 0, @barSize.width, @barSize.height)

  _animateNextFrame: =>
    return unless @isAnimating
    @_currentOffset = if _.isUndefined(@_currentOffset) then 1 else (@_currentOffset + 1) % @barCount
    @_draw(@_canvasContext, @_currentOffset)
    _.delay @_animateNextFrame, 50

  _clearFrame: (context) ->
    context.clearRect(0, 0, @_canvasElement.clientWidth, @_canvasElement.clientHeight)

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
