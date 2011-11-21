
class window.Cartilage.Views.MatrixView extends Cartilage.Views.ListView

  className: "list-view matrix-view"

  events: _.extend {
    "mouseup": "onMouseUp",
    "mousemove": "onMouseMove"
  }, Cartilage.Views.ListView.prototype.events

  render: =>
    super
    ($ @el).append ($ "<div/>").addClass("overlay").hide()
    @

  #
  # Handles click events for the entire list elements, including the list
  # container.
  #
  onMouseDown: (event) =>
    super(event)

    # Only handle this event if the primary mouse button was pressed...
    return unless event.button is 0

    @isDragging = true
    @originX = event.pageX - ($ @el).offset().left
    @originY = event.pageY - ($ @el).offset().top
    @originScrollTop = ($ @el).scrollTop()
    @originScrollLeft = ($ @el).scrollLeft()
    (@$ ".overlay").css {
      "width": "0px",
      "height": "0px",
      "left": event.pageX,
      "top": event.pageY
    }

  onMouseUp: (event) =>
    @isDragging = false
    (@$ ".overlay").hide().css {
      width: "0px",
      height: "0px"
    }

  onMouseMove: (event) =>
    return unless @isDragging

    overlayElement = (@$ ".overlay")
    overlayElement.show()

    left   = @originX
    top    = @originY
    width  = (event.pageX - ($ @el).offset().left) - @originX
    height = (event.pageY - ($ @el).offset().top) - @originY

    if width < 0
      width = -width
      left = (event.pageX - ($ @el).offset().left)
    else
      left = @originX

    if height < 0
      height = -height
      top = (event.pageY - ($ @el).offset().top)
    else
      top = @originY

    if ($ @el).scrollTop() == @originScrollTop
      top = top + @originScrollTop
    else if ($ @el).scrollTop() > @originScrollTop
      top = top + @originScrollTop
      height = height + (($ @el).scrollTop() - @originScrollTop)
    else if ($ @el).scrollTop() < @originScrollTop
      top = top + ($ @el).scrollTop()
      height = height + (($ @el).scrollTop() + @originScrollTop)

    overlayElement.css {
      left: left + 'px',
      top: top + 'px',
      width: width + 'px',
      height: height + 'px'
    }

    _.each (@$ "li"), (element) =>
      if ($ element).overlapped left, (top - ($ @el).scrollTop()), width, height
        @selectAnother element
      else
        @deselect element

  #
  # Handles key down events while the view is focused.
  #
  onKeyDown: (event) =>
    keyCode = event.keyCode

    # Arrow Keys
    if keyCode in [ 37..40 ] or keyCode in [ 63232..63235 ]

      event.preventDefault()

      # Select the first item if there is no selection when the first key press
      # occurs.
      return @selectFirst() unless @selected.length > 0

      # Route the key event to the proper handler based on the combination of
      # keys that were pressed.
      if event.shiftKey or event.metaKey
        return @expandSelectionLeft  event if keyCode in [ 37, 63234 ]
        return @expandSelectionUp    event if keyCode in [ 38, 63232 ]
        return @expandSelectionRight event if keyCode in [ 39, 63235 ]
        return @expandSelectionDown  event if keyCode in [ 40, 63233 ]
      else
        return @moveSelectionLeft    event if keyCode in [ 37, 63234 ]
        return @moveSelectionUp      event if keyCode in [ 38, 63232 ]
        return @moveSelectionRight   event if keyCode in [ 39, 63235 ]
        return @moveSelectionDown    event if keyCode in [ 40, 63233 ]

    # Command-A
    if keyCode == 65 and event.metaKey
      event.preventDefault()
      return @selectAll()

    # Enter Key
    if keyCode == 13
      event.preventDefault()
      return @open event.target

    # Delete Key
    if keyCode in [ 8, 46 ]
      event.preventDefault()
      return @remove event.target

    # Space Key
    return event.preventDefault() if keyCode == 32

  #
  # Moves the selection to the left. If there is no selection or the selection
  # is already at the first-most element, the first element will become or
  # remain selected.
  #
  moveSelectionLeft: (e) =>
    element = ($ @focusedElement).prev "li"
    if element.length > 0
      @clearSelection() and @select element
      @focusedElement = ($ element).focus()

  #
  # Moves the selection to the right. If there is no selection the first
  # item will be selected.
  #
  moveSelectionRight: (e) =>
    element = ($ @focusedElement).next "li"
    if element.length > 0
      @clearSelection() and @select element
      @focusedElement = ($ element).focus()

  #
  # Moves the selection to the item visually below the selected item. If there
  # is no selection the first item will be selected.
  #
  moveSelectionDown: (e) ->
    centerPoint    = ($ @focusedElement).centerPoint()
    centerPoint.y += ($ @focusedElement).outerHeight(true)

    elements = ($ @focusedElement).nextAll "li"
    element  = elements.filter (idx, element) ->
      ($ element).containsPoint(centerPoint)

    if element.length > 0
      @clearSelection() and @select element
      @focusedElement = ($ element).focus()

  #
  # Moves the selection to the item visually above the selected item. If there
  # is no selection the first item will be selected.
  #
  moveSelectionUp: (e) ->
    centerPoint    = ($ @focusedElement).centerPoint()
    centerPoint.y -= ($ @focusedElement).outerHeight(true)

    elements = ($ @focusedElement).prevAll "li"
    element  = elements.filter (idx, element) ->
      ($ element).containsPoint(centerPoint)

    if element.length > 0
      @clearSelection() and @select element
      @focusedElement = ($ element).focus()

  #
  # Expands the selection leftward from the currently selected element.
  #
  expandSelectionLeft: (e) ->
    element = ($ @focusedElement).prev "li"
    if element.length > 0
      @selectAnother element
      @focusedElement = ($ element).focus()

  #
  # Expands the selection rightward from the currently selected element.
  #
  expandSelectionRight: (e) ->
    element = ($ @focusedElement).next "li"
    if element.length > 0
      @selectAnother element
      @focusedElement = ($ element).focus()

  #
  # Expands the selection downward from the currently selected element.
  #
  expandSelectionDown: (e) ->
    centerPoint    = ($ @focusedElement).centerPoint()
    centerPoint.y += ($ @focusedElement).outerHeight(true)

    elements = ($ @focusedElement).nextAll "li"
    element  = elements.filter (idx, element) ->
      ($ element).containsPoint(centerPoint)

    @selectAnother element if element.length > 0
    @focusedElement = ($ element).focus()

  #
  # Expands the selection upward from the currently selected element.
  #
  expandSelectionUp: (e) ->
    centerPoint    = ($ @focusedElement).centerPoint()
    centerPoint.y -= ($ @focusedElement).outerHeight(true)

    elements = ($ @focusedElement).prevAll "li"
    element  = elements.filter (idx, element) ->
      ($ element).containsPoint(centerPoint)

    @selectAnother element if element.length > 0
    @focusedElement = ($ element).focus()
