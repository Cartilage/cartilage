#
# Split View
#
# Manages a split view layout with either two side-by-side views or views
# stacked on top and bottom.
#

class window.Cartilage.Views.SplitView extends Cartilage.View

  # Properties ---------------------------------------------------------------

  #
  # The first view in split view. This is the view on the left when the
  # orientation is set to vertical or the view on the top when set to
  # horizontal.
  #
  @property "firstView", default: null

  #
  # The second view in split view. This is the view on the right when the
  # orientation is set to vertical or the view on the bottom when set to
  # horizontal.
  #
  @property "secondView", default: null

  #
  # The orientation of the split view, either "horizontal" or "vertical".
  # Defaults to "vertical".
  #
  @property "orientation", default: "vertical"

  #
  # Whether or not the split view is resizable. Defaults to true.
  #
  @property "isResizable", default: yes

  # Internal Properties ------------------------------------------------------

  # Events -------------------------------------------------------------------

  events:
    "mousedown .drag-handle": "onMouseDown"
    "mouseup": "onMouseUp",
    "mousemove": "onMouseMove"

  # --------------------------------------------------------------------------

  #
  # Initializes a new instance of the split view. Pass firstView and
  # secondView as options, at a minimum, to specify the view setup.
  #
  initialize: (options = {}) ->

    # Initialize View Containers
    ($ @el).append @_firstViewContainer = @make "div",
      class: "first-view"
    ($ @el).append @_secondViewContainer = @make "div",
      class: "second-view"

    # Initialize Drag Handle
    if @isResizable
      ($ @el).append @dragElement = @make "div",
        class: "drag-handle"

    # Set Orientation
    ($ @el).addClass @orientation

    # Observe for window resize events and re-render the view when it occurs...
    ($ window).on "resize", @handleWindowResize

    super(options)

  prepare: ->

    super()

    @addSubview @firstView, @_firstViewContainer
    @addSubview @secondView, @_secondViewContainer

    if @orientation is "vertical"
      @position(($ @_firstViewContainer).width())
    else
      @position(0)

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
      minWidth = parseInt ($ @_firstViewContainer).css("min-width")
      maxWidth = parseInt ($ @_firstViewContainer).css("max-width")

      if newPosition < minWidth
        newPosition = minWidth
      else if newPosition > maxWidth
        newPosition = maxWidth

      if options["animated"]
        ($ @_firstViewContainer).css { left: '' }
        ($ @_firstViewContainer).animate { width: newPosition + 'px' }, 250
        ($ @_secondViewContainer).css { width: '' }
        ($ @_secondViewContainer).animate { left: newPosition + 'px' }, 250
      else
        ($ @_firstViewContainer).css { width: newPosition + 'px', left: '' }
        ($ @_secondViewContainer).css { left: newPosition + 'px', width: '' }

      ($ @dragElement).css("left", (newPosition - ($ @dragElement).width() / 2) + "px")

    else
      minHeight = parseInt ($ @_secondViewContainer).css("min-height")
      maxHeight = parseInt ($ @_secondViewContainer).css("max-height")

      if newPosition < minHeight
        newPosition = minHeight
      else if newPosition > maxHeight
        newPosition = maxHeight

      bottom = ($ @el).height() - newPosition

      if options["animated"]
        ($ @_firstViewContainer).css { bottom: '' }
        ($ @_firstViewContainer).animate { height: bottom + 'px' }, 250
        ($ @_secondViewContainer).css { height: '' }
        ($ @_secondViewContainer).animate { top: bottom + "px" }, 250
      else
        ($ @_firstViewContainer).css { height: bottom + 'px', bottom: '' }
        ($ @_secondViewContainer).css { top: bottom + 'px', height: newPosition + 'px' }

      ($ @dragElement).css("top", (newPosition - ($ @dragElement).height() / 2) + "px")

    @_currentPosition = newPosition
    @trigger("resize")

  handleWindowResize: (event) =>
    @position(@_currentPosition) if @_currentPosition?

  setFirstView: (view) ->
    @firstView.removeFromSuperview() if @firstView
    @firstView = view
    @addSubview view, @_firstViewContainer

  setSecondView: (view) ->
    @secondView.removeFromSuperview() if @secondView
    @secondView = view
    @addSubview view, @_secondViewContainer

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
