
class window.Aphid.Views.ListView extends Backbone.View

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

  initialize: (options = {}) ->

    # Apply options
    @allowsRemove      = options["allowsRemove"] || (@allowsRemove ?= false)
    @allowsDeselection = options["allowsDeselection"] || (@allowsDeselection ?= true)
    @itemView          = options["itemView"]

    # Bind to collection
    @collection.bind "reset", @render
    @collection.bind "add", @render
    @collection.bind "remove", @render

    # Set a tab index on the element, if necessary, to enable focus support
    # for the list view and its items
    ($ @el).attr("tabindex", 0) unless ($ @el).attr("tabindex")

  render: =>
    ($ @el).empty()
    _.each @renderModels(), (element) => element.appendTo ($ @el)
    @

  renderModels: ->
    items = _.map @collection.models, (model) =>
      itemElement = ($ '<li />')
      itemElement.attr("tabindex", ($ @el).attr("tabindex"))
      itemElement.data("model", model)
      if @itemView?
        itemView = new @itemView { model: model }
        itemElement.html itemView.render().el
        itemElement.data "view", itemView
      else
        itemElement.html model.constructor.name

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
    ($ element).focus()
    @focusedElement = ($ element)
    @trigger "select", @selected

  selectAnother: (e) =>
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
    element = ($ @el).find "li:first-of-type"
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
      @selectAnother element

    else if event.shiftKey
      element = event.target
      @expandSelectionToElement element

  #
  # Handles focus events.
  #
  onFocus: (event) =>
    @focusedElement = event.target
    unless event.metaKey
      @select event.target

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
    ].sort()

    # Select the elements in the requested indexes.
    elements = ($ @el).find("li").slice indexes...
    _.each elements, @selectAnother
