class window.Cartilage.Views.ListView extends Backbone.View

  tagName: "ul"
  className: "list-view"

  events:
    "dblclick li": "open"
    "focus li": "onFocus"
    "keydown": "onKeyDown"
    "mousedown": "onMouseDown"

  selected:
    new Backbone.Collection

  allowsRemove: false
  allowsDeselection: true
  allowsMultipleSelection: false

  initialize: (options = {}) ->

    # Apply options
    @allowsRemove = options["allowsRemove"] || (@allowsRemove ?= false)
    @allowsDeselection = options["allowsDeselection"] || (@allowsDeselection ?= true)
    @allowsMultipleSelection = options["allowsMultipleSelection"] || (@allowsMultipleSelection ?= true)
    @itemView = options["itemView"]

    # Bind to collection
    @collection.bind "reset", @render
    @collection.bind "add", @addModel
    @collection.bind "remove", @render # TODO Don't re-render the entire view for removals

    # Set a tab index on the element, if necessary, to enable focus support
    # for the list view and its items
    ($ @el).attr("tabindex", 0) unless ($ @el).attr("tabindex")

  render: =>
    ($ @el).empty()
    _.each @renderModels(), (element) => element.appendTo ($ @el)
    @

  renderModels: ->
    items = _.map @collection.models, (model) =>
      @renderModel(model)

  renderModel: (model) =>
    itemElement = ($ "<li />")
    itemElement.attr("tabindex", ($ @el).attr("tabindex"))
    itemElement.data("model", model)
    if @itemView?
      itemView = new @itemView { model: model }
      itemElement.html itemView.render().el
      itemElement.data "view", itemView
    else
      itemElement.html model.constructor.name
    itemElement

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
    element = unless _.isUndefined(e.target) then e.target else e
    model = ($ element).data("model")

    # Do not attempt to select the element if it is already selected.
    return if model in @selected.models

    # If an element is already selected, deselect it before continuing.
    @clearSelection { silent: true } if @selected.length > 0

    @selected.add model
    ($ element).addClass "selected"
    ($ element).focus() unless ($ element).is(":focus")
    @focusedElement = ($ element)
    @trigger "select", @selected

  selectAnother: (e) =>
    # If multiple selection is not allowed, simply select the requested item
    # and return instead of adding it to the selection.
    unless @allowsMultipleSelection
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
    return unless @allowsMultipleSelection
    elements = ($ @el).find "li:not(.selected)"
    _.each elements, @selectAnother

  #
  # Deselects the specified list view item, if it is currently selected.
  # Returns true if the item was deselected or false if no action was
  # performed.
  #
  deselect: (element) ->
    model = ($ element).data("model")
    ($ element).removeClass "selected"
    @trigger "deselect", element
    @selected.remove model

  #
  # Deselects the specified list view item, if it is currently selected.
  # Returns true if the item was deselected or false if no action was
  # performed.
  #
  clearSelection: (options = {}) ->
    ($ @el).find("li.selected").removeClass "selected"
    @trigger("clear", @selected) unless options["silent"]
    @selected.reset()

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
    @trigger "remove", @selected
    @collection.remove @selected.models
    @selected.reset()

  #
  # Handles click events for the entire list elements, including the list
  # container.
  #
  onMouseDown: (event) =>

    # Clear the selection if the user clicks in the list container.
    @clearSelection() if @allowsDeselection and event.target.tagName == "UL"

    if event.metaKey
      element = event.target
      @selectAnother ($ element).parents("li") || element
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
