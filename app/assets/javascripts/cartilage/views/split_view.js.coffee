#
# Split View
#
# Manages a split view layout with either two side-by-side views or views
# stacked on top and bottom.
#

class window.Cartilage.Views.SplitView extends Cartilage.View

  events:
    "mousedown .drag-handle": "onMouseDown"
    "mouseup": "onMouseUp",
    "mousemove": "onMouseMove"

  #
  # The first view in split view. This is the view on the left when the
  # orientation is set to vertical or the view on the top when set to
  # horizontal.
  #
  firstView: null
  firstElement: null

  #
  # The second view in split view. This is the view on the right when the
  # orientation is set to vertical or the view on the bottom when set to
  # horizontal.
  #
  secondView: null
  secondElement: null

  #
  # The orientation of the split view, either "horizontal" or "vertical".
  # Defaults to "vertical".
  #
  orientation: null

  #
  # Whether or not the split view is resizable. Defaults to true.
  #
  isResizable: null

  #
  # Initializes a new instance of the split view. Pass firstView and
  # secondView as options, at a minimum, to specify the view setup.
  #
  initialize: (options = {}) ->

    # Options
    @firstView     = options["firstView"]
    @secondView    = options["secondView"]
    @orientation   = options["orientation"] || (@orientation ?= "vertical")
    @isResizable   = unless _.isUndefined(options["isResizable"]) then options["isResizable"] else @isResizable ?= true

    # Elements
    @firstElement  = @make("div", { class: "first-view" })
    @secondElement = @make("div", { class: "second-view" })
    if @isResizable
      @dragElement = @make("div", { class: "drag-handle" })

    # Observe for window resize events and re-render the view when it occurs...
    ($ window).on "resize", @handleWindowResize

  prepare: ->
    ($ @el).append @firstElement
    ($ @el).append @secondElement
    if @isResizable
      ($ @el).append @dragElement

    ($ @el).addClass @orientation

    @addSubview @firstView, @firstElement
    @addSubview @secondView, @secondElement

    @position(($ @firstElement).width())

  cleanup: ->
    ($ window).off "resize", @handleWindowResize
    @firstView.cleanup() if @firstView and @firstView.cleanup
    @secondView.cleanup() if @secondView and @secondView.cleanup
    super()

  #
  # Sets the position of the divider that separates the two views. In the case
  # of a horizontal split view, this is the height of the secondView. For
  # vertical split views, this is the width of the firstView.
  #
  position: (newPosition, options = {}) =>
    return @_currentPosition unless newPosition?

    if @orientation is "vertical"
      minWidth = parseInt ($ @firstElement).css("min-width")
      maxWidth = parseInt ($ @firstElement).css("max-width")

      if newPosition < minWidth
        newPosition = minWidth
      else if newPosition > maxWidth
        newPosition = maxWidth

      if options["animated"]
        ($ @firstElement).css { left: '' }
        ($ @firstElement).animate { width: newPosition + 'px' }, 250
        ($ @secondElement).css { width: '' }
        ($ @secondElement).animate { left: newPosition + 'px' }, 250
      else
        ($ @firstElement).css { width: newPosition + 'px', left: '' }
        ($ @secondElement).css { left: newPosition + 'px', width: '' }

      ($ @dragElement).css("left", (newPosition - ($ @dragElement).width() / 2) + "px")

    else
      minHeight = parseInt ($ @firstElement).css("min-height")
      maxHeight = parseInt ($ @firstElement).css("max-height")

      if newPosition < minHeight
        newPosition = minHeight
      else if newPosition > maxHeight
        newPosition = maxHeight

      if options["animated"]
        ($ @firstElement).css { bottom: '' }
        ($ @firstElement).animate { height: newPosition + 'px' }, 250
        ($ @secondElement).css { height: '' }
        ($ @secondElement).animate { top: newPosition + "px" }, 250
      else
        ($ @firstElement).css { height: newPosition + 'px', bottom: '' }
        ($ @secondElement).css { top: newPosition + "px", height: '' }

      ($ @dragElement).css("top", (newPosition - ($ @dragElement).height() / 2) + "px")

    @_currentPosition = newPosition
    @trigger("resize")

  handleWindowResize: (event) =>
    @position(@_currentPosition) if @_currentPosition?

  setFirstView: (view) ->
    @firstView.removeFromSuperview() if @firstView
    @firstView = view
    @addSubview view, @firstElement

  setSecondView: (view) ->
    @secondView.removeFromSuperview() if @secondView
    @secondView = view
    @addSubview view, @firstElement

  onMouseDown: (event) =>
    return unless @isResizable
    @isResizing = true

  onMouseUp: (event) =>
    return unless @isResizable
    @isResizing = false

  onMouseMove: (event) =>
    return unless @isResizable and @isResizing

    event.preventDefault()

    if @orientation is "vertical"
      offset = ($ @el).offset().left
      @position((event.pageX - (($ @dragElement).width() / 2)) - offset)
    else
      offset = ($ @el).offset().top
      @position((event.pageY - (($ @dragElement).height() / 2)) - offset)
