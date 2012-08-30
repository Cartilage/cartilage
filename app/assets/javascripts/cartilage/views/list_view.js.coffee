#
# List View
#

class window.Cartilage.Views.ListView extends Cartilage.View

  tagName: "ul"

  events:
    "dblclick li": "open"
    "focus li": "onFocus"
    "keydown": "onKeyDown"
    "mousedown": "onMouseDown"
    "dragover": "onDragOver"
    "drop": "onDrop"

  @draggedItem: false

  initialize: (options = {}) ->

    # Apply options
    @allowsRemove            = unless _.isUndefined(options["allowsRemove"]) then options["allowsRemove"] else @allowsRemove ?= true
    @allowsSelection         = unless _.isUndefined(options["allowsSelection"]) then options["allowsRemove"] else @allowsSelection ?= true
    @allowsDeselection       = unless _.isUndefined(options["allowsDeselection"]) then options["allowsDeselection"] else @allowsDeselection ?= true
    @allowsMultipleSelection = unless _.isUndefined(options["allowsMultipleSelection"]) then options["allowsMultipleSelection"] else @allowsMultipleSelection ?= true
    @allowsDragToReorder     = unless _.isUndefined(options["allowsDragToReorder"]) then options["allowsDragToReorder"] else @allowsDragToReorder ?= true
    @itemView                = options["itemView"]

    # Defaults
    @selected = new Backbone.Collection

    # Set a tab index on the element, if necessary, to enable focus support
    # for the list view and its items
    ($ @el).attr("tabindex", 0) unless ($ @el).attr("tabindex")

    # Observe Collection
    if @collection
      @observe(@collection, "add", @addModel)
      @observe(@collection, "reset", @prepare) # TODO Don't re-render the entire view for removals
      @observe(@collection, "remove", @prepare) # TODO Don't re-render the entire view for removals

  cleanup: ->
    @clearSelection { silent: true }
    super()

  prepare: ->
    # Clean up all existing item views and their container elements.
    (@$ "li").each (idx, element) ->
      if view = ($ element).data("view")
        view.cleanup()
      ($ element).remove()

    _.each @renderModels(), (view) => @addSubview view
    @restoreSelection() if @selected.models.length > 0

  renderModels: =>
    items = _.map @collection.models, (model) =>
      @renderModel(model)

  renderModel: (model) =>
    new @itemView { model: model, listView: @ } if @itemView?

  addModel: (model) =>
    index   = _.indexOf(@collection.models, model) + 1
    element = (@$ "li:nth-of-type(#{index})")
    if element.length == 1
      @renderModel(model).insertBefore(element)
    else
      @renderModel(model).appendTo @el

  #
  # Selects the specified list item. Returns true if the item was selected or
  # false if no action was performed.
  #
  select: (e) =>
    return unless @allowsSelection

    element = unless _.isUndefined(e.target) then e.target else e
    model = ($ element).data("model")

    # Do not attempt to select the element if it is already selected.
    return if model in @selected.models

    # If an element is already selected, deselect it before continuing.
    @clearSelection { silent: true } if @selected.length > 0

    @selected.add model
    ($ element).addClass "selected"
    # ($ element).focus() unless ($ element).is(":focus")
    @focusedElement = ($ element)
    @trigger "select", @selected

  selectAnother: (e) =>
    # If multiple selection is not allowed, simply select the requested item
    # and return instead of adding it to the selection.
    unless @allowsSelection and @allowsMultipleSelection
      @select(e)
      return

    element = e.target || e
    model = ($ element).data("model")

    # Do not attempt to select the element if it is already selected.
    return if model in @selected.models

    @selected.add model
    ($ element).addClass "selected"
    @trigger "select", @selected

  #
  # Selects the first element in the list.
  #
  selectFirst: ->
    element = ($ @el).find("li").first()
    @select element

  #
  # Selects the last element in the list.
  #
  selectLast: ->
    element = ($ @el).find "li:last-of-type"
    @select element

  #
  # Selects all elements in the list.
  #
  selectAll: ->
    return unless @allowsSelection and @allowsMultipleSelection
    elements = ($ @el).find "li:not(.selected)"
    _.each elements, @selectAnother

  #
  # Restores the selection after a re-rendering.
  #
  restoreSelection: =>
    elements = ($ @el).find "li"
    _.each elements, (element) =>
      model = ($ element).data("model")
      if model in @selected.models
        ($ element).addClass("selected")
      else
        @selected.remove model

  #
  # Deselects the specified list view item, if it is currently selected.
  # Returns true if the item was deselected or false if no action was
  # performed.
  #
  deselect: (element) ->
    model = ($ element).data("model")
    ($ element).removeClass "selected"
    @selected.remove model
    @trigger "deselect", element

  #
  # Deselects the specified list view item, if it is currently selected.
  # Returns true if the item was deselected or false if no action was
  # performed.
  #
  clearSelection: (options = {}) ->
    ($ @el).find("li.selected").removeClass "selected"
    @selected.reset(null, { silent: options["silent"] })
    @trigger("clear", @selected) unless options["silent"]

  #
  # Opens the selected item(s).
  #
  open: (e) ->
    @trigger "open", @selected

  #
  # Removes the selected item(s).
  #
  remove: (e) =>
    return unless @allowsRemove
    @collection.remove @selected.models
    @selected.reset()
    @trigger "remove", @selected

  #
  # Handles click events for the entire list elements, including the list
  # container.
  #
  onMouseDown: (event) =>

    # Get the list item element
    element = ($ event.target).parents("li") || event.target

    # Clear the selection if the user clicks in the list container.
    @clearSelection() if @allowsDeselection and event.target.tagName == "UL"

    if event.metaKey
      model = ($ element).data("model")
      if model in @selected.models
        @deselect element
      else
        @selectAnother element
      event.preventDefault()

    else if event.shiftKey
      element = event.target
      @expandSelectionToElement ($ element).parents("li") || element
      event.preventDefault()

  #
  # Handles focus events.
  #
  onFocus: (event) =>
    @focusedElement = $(event.target).closest("li")
    @select @focusedElement unless event.metaKey
    event.preventDefault()

  #
  # Handles key down events while the view is focused.
  #
  onKeyDown: (event) =>
    keyCode = event.keyCode

    # Arrow Keys
    if keyCode in [ 38, 40, 63232, 63233 ]

      event.preventDefault()

      # Select the first item if there is no selection when the first key press
      # occurs.
      return @selectFirst() unless @selected.length > 0

      # Route the key event to the proper handler based on the combination of
      # keys that were pressed.
      if event.shiftKey or event.metaKey
        return @expandSelectionUp    event if keyCode in [ 38, 63232 ]
        return @expandSelectionDown  event if keyCode in [ 40, 63233 ]
      else
        return @moveSelectionUp      event if keyCode in [ 38, 63232 ]
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

  onDragOver: (event) =>
    allowed = true

    # Ensure that the list item belongs to us...
    unless "application/x-list-view-item-id" in event.dataTransfer.types
      # console.log "Item not of the right type"
      allowed = false

    unless Cartilage.Views.ListView.draggedItem.model in @collection.models
      # console.log "Item not in listView collection", @collection.models, Cartilage.Views.ListView.draggedItem
      allowed = false

    event.preventDefault() if allowed

  onDrop: (event) =>
    draggedElementId = event.dataTransfer.getData("application/x-list-view-item-id")

    element = ($ event.target).parents("li.list-view-item")[0] || ($ event.target)

    if element[0] and element[0].tagName is "LI"
      if event.originalEvent.offsetY < (($ element).height() / 2)
        ($ "##{draggedElementId}").detach().insertBefore(($ element))
      else
        ($ "##{draggedElementId}").detach().insertAfter(($ element))
      ($ element).removeClass("drop-before").removeClass("drop-after")

    # Clear the global draggedItem reference
    Cartilage.Views.ListView.draggedItem = false

  #
  # Moves the selection to the item visually above the selected item. If there
  # is no selection the first item will be selected.
  #
  moveSelectionUp: (e) =>
    element = ($ @focusedElement).prev "li"
    if element.length > 0
      @clearSelection { silent: true } and @select element
      @focusedElement = ($ element).focus()

  #
  # Moves the selection to the item visually below the selected item. If there
  # is no selection the first item will be selected.
  #
  moveSelectionDown: (e) =>
    element = ($ @focusedElement).next "li"
    if element.length > 0
      @clearSelection { silent: true } and @select element
      @focusedElement = ($ element).focus()

  #
  # Expands the selection downward from the currently selected element.
  #
  expandSelectionDown: (e) ->
    element = ($ @focusedElement).next "li"
    if element.length > 0
      @selectAnother element
      @focusedElement = ($ element).focus()

  #
  # Expands the selection upward from the currently selected element.
  #
  expandSelectionUp: (e) ->
    element = ($ @focusedElement).prev "li"
    if element.length > 0
      @selectAnother element
      @focusedElement = ($ element).focus()

  #
  # Expands the selection from the currently selected element to the passed
  # element.
  #
  expandSelectionToElement: (element) ->
    indexes = [
      ($ @focusedElement).index(),
      ($ element).index()
    ].sort (a, b) -> a - b

    # Increment the end range since slice does not include it...
    indexes[1] += 1

    # Select the elements in the requested indexes.
    elements = ($ @el).find("li").slice indexes...
    _.each elements, @selectAnother

  #
  # Scrolls the list view to fully expose the selected item if it is not
  # fully visible within the list view. Returns true or false depending on
  # whether the scroll was performed.
  #
  # scrollToSelectedItem: =>
  #   console.log "scrollToSelectedItem"
  #
  #   scrollElement = ($ @el).parent()[0]
  #   console.log scrollElement
  #
  #   if ($ scrollElement).scrollHeight < ($ scrollElement).innerHeight() and ($ scrollElement).scrollWidth < ($ scrollElement).innerWidth()
  #     console.log "returning"
  #     return
  #
  #   selectedItemTop     = @selectedElement.offset().top - ($ scrollElement).offset().top
  #   selectedItemBottom  = selectedItemTop + @selectedElement.innerHeight()
  #   selectedItemLeft    = @selectedElement.offset().left - ($ scrollElement).offset().left
  #   selectedItemRight   = selectedItemLeft + @selectedElement.innerWidth()
  #   currentScrollTop    = ($ scrollElement).scrollTop()
  #   currentScrollBottom = ($ scrollElement).scrollTop() + ($ scrollElement).innerHeight()
  #   currentScrollLeft   = ($ scrollElement).scrollLeft()
  #   currentScrollRight  = ($ scrollElement).scrollLeft() + ($ scrollElement).innerWidth()
  #   itemTopMargin       = parseInt(@selectedElement.css("margin-top"), 10)
  #   itemBottomMargin    = parseInt(@selectedElement.css("margin-bottom"), 10)
  #   itemLeftMargin      = parseInt(@selectedElement.css("margin-left"), 10)
  #   itemRightMargin     = parseInt(@selectedElement.css("margin-right"), 10)
  #   scrollTopValue      = selectedItemTop - itemTopMargin
  #   scrollLeftValue     = selectedItemLeft - itemLeftMargin
  #   shouldScrollTop     = false
  #   shouldScrollLeft    = false
  #
  #   # selectedItem is above current scroll position
  #   if selectedItemTop < currentScrollTop
  #     shouldScrollTop = true
  #
  #   # selectedItem is below current, viewable scroll position
  #   if selectedItemTop >= currentScrollBottom
  #     shouldScrollTop = true
  #
  #   # selectedItem is partially visible below the current, viewable scroll position
  #   else if selectedItemBottom > currentScrollBottom
  #     shouldScrollTop = true
  #     scrollTopValue = currentScrollTop + (selectedItemBottom - currentScrollBottom) + itemBottomMargin
  #
  #   # selectedItem is left of current scroll position
  #   if selectedItemLeft < currentScrollLeft
  #     shouldScrollLeft = true
  #
  #   # selectedItem is right of current, viewable scroll position
  #   if selectedItemLeft >= currentScrollRight
  #     shouldScrollLeft = true
  #
  #   # selectedItem is partially visible below the current, viewable scroll position
  #   else if selectedItemRight > currentScrollRight
  #     shouldScrollLeft = true
  #     scrollLeftValue = currentScrollLeft + (selectedItemRight - currentScrollRight) + itemRightMargin
  #
  #   if shouldScrollTop or shouldScrollLeft
  #     ($ @el).scrollTop(scrollTopValue) if shouldScrollTop
  #     ($ @el).scrollLeft(scrollLeftValue) if shouldScrollLeft
  #
  #   (shouldScrollTop or shouldScrollLeft)
