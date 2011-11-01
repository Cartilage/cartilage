#
# Split View
#
# Manages a split view layout with either two side-by-side views or views
# stacked on top and bottom.
#

class window.Cartilage.Views.SplitView extends Backbone.View

  className: "split-view"

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
    @firstElement  = ($ '<div class="first"></div>')
    @secondElement = ($ '<div class="second"></div>')

    # Observe for window resize events and re-render the view when it occurs...
    ($ window).resize => @position(@_currentPosition) if @_currentPosition?

  render: =>
    ($ @el).addClass @orientation

    @firstElement.html @firstView.render().el
    @secondElement.html @secondView.render().el

    ($ @el).append @firstElement
    ($ @el).append @secondElement

    @

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

    @trigger("resize");
