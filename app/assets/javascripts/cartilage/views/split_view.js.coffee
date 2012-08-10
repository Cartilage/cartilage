#
# Split View
#
# Manages a split view layout with either two side-by-side views or views
# stacked on top and bottom.
#

class window.Cartilage.Views.SplitView extends Cartilage.View

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
  # Initializes a new instance of the split view. Pass firstView and
  # secondView as options, at a minimum, to specify the view setup.
  #
  initialize: (options = {}) ->
    @firstView     = options["firstView"]
    @secondView    = options["secondView"]
    @orientation   = options["orientation"] || "vertical"
    @firstElement  = @make("div", { class: "first-view" })
    @secondElement = @make("div", { class: "second-view" })

    # Observe for window resize events and re-render the view when it occurs...
    ($ window).on "resize", @handleWindowResize

  prepare: ->
    ($ @el).append @firstElement
    ($ @el).append @secondElement

    ($ @el).addClass @orientation

    @addSubview @firstView, @firstElement
    @addSubview @secondView, @secondElement

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

    @_currentPosition = newPosition

    if @orientation is "vertical"
      # left = ($ @el).width() - position
      if options["animated"]
        ($ @firstElement).css { left: '' }
        ($ @firstElement).animate { width: newPosition + 'px' }, 250
        ($ @secondElement).css { width: '' }
        ($ @secondElement).animate { left: newPosition + 'px' }, 250
      else
        ($ @firstElement).css { width: newPosition + 'px', left: '' }
        ($ @secondElement).css { left: newPosition + 'px', width: '' }

    else
      bottom = ($ @el).height() - newPosition
      if options["animated"]
        ($ @firstElement).css { bottom: '' }
        ($ @firstElement).animate { height: bottom + 'px' }, 250
        ($ @secondElement).css { height: '' }
        ($ @secondElement).animate { top: bottom + "px" }, 250
      else
        ($ @firstElement).css { height: bottom + 'px', bottom: '' }
        ($ @secondElement).css { top: bottom + "px", height: '' }

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
