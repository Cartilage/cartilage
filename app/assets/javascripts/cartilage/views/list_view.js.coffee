#
# List View
#
# Manages a list of items as an unordered list (<ul/>), providing rich
# interaction support (selection, keyboard navigation, removal, reordering,
# etc).
#

#= require cartilage/views/list_view_item

class window.Cartilage.Views.ListView extends Cartilage.View

  # Properties ---------------------------------------------------------------

  #
  # Whether or not items may be removed from the list view through keyboard
  # actions (i.e. pressing delete while the item is selected).
  #
  @property "allowsRemove", default: no

  #
  # Whether or not selections of list view items can be made in the list
  # view.
  #
  @property "allowsSelection", default: yes

  #
  # Whether or not the list view may clear its selection through user
  # actions, such as clicking on the empty areas of a list view.
  #
  @property "allowsDeselection", default: yes

  #
  # Whether or not multiple list view items may be selected at once.
  #
  @property "allowsMultipleSelection", default: no

  #
  # Whether or not the user can drag list view items around to reorder them.
  #
  @property "allowsDragToReorder", default: no

  #
  # The default class for all list view items that are not explicitly
  # initialized.
  #
  @property "itemView", default: Cartilage.Views.ListViewItem

  #
  # An array containing the view of each item rendered as a part of the list
  #
  @property "listItemViews", access: READONLY, default: []

  #
  # A collection containing the models of the currently selected items.
  #
  # TODO Rename to selectedModels
  # TODO Add selectedItems
  @property "selected", access: READONLY 

  #
  # A collection containing all of the list view items managed by the list
  # view.
  #
  @property "items", access: READONLY, default: new Backbone.Collection

  # --------------------------------------------------------------------------

  @draggedItem: undefined

  events:
    "dblclick ul.list-view-items-container > li": "open"
    "click ul.list-view-items-container > li": "onFocus"
    "keydown ul.list-view-items-container": "onKeyDown"
    "mousedown ul.list-view-items-container": "onMouseDown"
    "dragover ul.list-view-items-container": "onDragOver"
    "drop ul.list-view-items-container": "onDrop"

  initialize: (options = {}) ->
    # Initialize the View
    super(options)

    # Initialize List View Items Container
    ($ @el).append @_listViewItemsContainer = @make "ul",
      class: "list-view-items-container"
      tabindex: 0

    # Keep the selected collection in the same order as the view collection
    @_selected = new Backbone.Collection(
      null,
      comparator: (item) =>
        @collection.indexOf(item)
      )

    # Observe Collection
    @observe @collection, "add", @addModel
    @observe @collection, "reset", @update # TODO Don't re-render the entire view for removals
    @observe @collection, "remove", @prepare # TODO Don't re-render the entire view for removals

  prepare: ->

    # Prepare the View
    super()

    # Update the View
    @update()

  update: ->
    # Clean up all existing item views and their container elements.
    (@$ "ul.list-view-items-container > li.list-view-item").each (idx, element) =>
      @removeItem(element)

    _.each @renderModels(), (view) => @addItem(view)
    @restoreSelection() if @_selected.models.length > 0

  renderModels: =>
    items = _.map @collection.models, (model) =>
      @renderModel(model)

  renderModel: (model) =>
    if @itemView? then new @itemView { model: model, listView: @ } else console.warn("Could not find corresponding itemView for #{@constructor.name}")

  addModel: (model) =>
    @addItem @renderModel(model)

  #
  # Adds an already instantiated list view item (must derive from
  # Cartilage.Views.ListViewItem) to the list view. The list view item's
  # model will automatically be added to the list view's collection, but
  # will not trigger any notifications that it was added.
  #
  addItem: (item, container = @_listViewItemsContainer) =>
    # Store the view in order in the _listItemView array so we can
    # insert views in the correct order.
    @_listItemViews.splice(@collection.indexOf(item.model), 0, item)

    # TODO Ensure that the item derives from ListViewItem
    @addSubview item, container

    @collection.add item.model, { silent: true }

  #
  # Removes a passed element from the list view's superview as well
  # as from the @_listViewItems array.
  # 
  removeItem: (element) =>
    if view = ($ element).data("view")
      view.removeFromSuperview()
      _.remove(@_listViewItems, view) if @_listViewItems?
    else
      ($ element).remove()


  #
  # Override View's insertSubviewItem method so a list view item
  # can be added at the correct position in the list
  #
  insertSubviewElement: (view, container) ->
    if @collection.length == 1
      ($ container ).append(view.el)
    else
      index = _.indexOf(@_listItemViews, view)
      if index == -1
        ($ container ).append(view.el)
      else if index == 0 
        ($ container ).prepend(view.el)
      else
        ($ @_listItemViews[index - 1].el ).after(view.el)

  #
  # Selects the specified list item. Returns true if the item was selected or
  # false if no action was performed.
  #
  select: (e) =>
    return unless @allowsSelection

    element = unless _.isUndefined(e.target) then e.target else e
    model = ($ element).data("model")

    # Do not attempt to select the element if it is already selected.
    return if model in @_selected.models

    # If an element is already selected, deselect it before continuing.
    if @allowsMultipleSelection
      # In multi-select, do a full reset so observing "reset" on @_selected works as expected
      @clearSelection() if @_selected.length > 0
    else
      # In single select, call deselect on each selected element so observing "deselect" works as expected
      _.each(($ @el).find("li.list-view-item.selected"), (element) => @deselect(element))

    @_selected.add model
    ($ element).addClass "selected"
    # ($ element).focus() unless ($ element).is(":focus")
    @focusedElement = ($ element)
    @trigger "select", @_selected

  selectAnother: (e) =>
    # If multiple selection is not allowed, simply select the requested item
    # and return instead of adding it to the selection.
    unless @allowsSelection and @allowsMultipleSelection
      @select(e)
      return

    element = e.target || e
    model = ($ element).data("model")

    # Do not attempt to select the element if it is already selected.
    return if model in @_selected.models

    @_selected.add model
    ($ element).addClass "selected"
    @trigger "select", @_selected

  #
  # Selects the first element in the list.
  #
  selectFirst: ->
    element = ($ @el).find("ul.list-view-items-container > li.list-view-item").first()
    @select element

  #
  # Selects the last element in the list.
  #
  selectLast: ->
    element = ($ @el).find "ul.list-view-items-container > li.list-view-item:last-of-type"
    @select element

  #
  # Selects all elements in the list.
  #
  selectAll: ->
    return unless @allowsSelection and @allowsMultipleSelection
    elements = ($ @el).find "ul.list-view-items-container > li.list-view-item:not(.selected)"
    _.each elements, @selectAnother

  #
  # Restores the selection after a re-rendering.
  #
  restoreSelection: =>
    elements = ($ @el).find "ul.list-view-items-container > li.list-view-item"
    _.each elements, (element) =>
      model = ($ element).data("model")
      if model in @_selected.models
        ($ element).addClass("selected")
      else
        @_selected.remove model

  #
  # Deselects the specified list view item, if it is currently selected.
  # Returns true if the item was deselected or false if no action was
  # performed.
  #
  deselect: (element) ->
    model = ($ element).data("model")
    ($ element).removeClass "selected"
    @_selected.remove model
    @trigger "deselect", element

  #
  # Deselects the specified list view item, if it is currently selected.
  # Returns true if the item was deselected or false if no action was
  # performed.
  #
  clearSelection: (options = {}) ->
    ($ @el).find("ul.list-view-items-container > li.list-view-item.selected").removeClass "selected"
    @_selected.reset(null, { silent: options["silent"] })
    @trigger("clear", @_selected) unless options["silent"]

  #
  # Opens the selected item(s).
  #
  open: (e) ->
    @trigger "open", @_selected

  #
  # Removes the selected item(s).
  #
  remove: (e) =>
    return unless @allowsRemove
    @collection.remove @_selected.models
    @_selected.reset()
    @trigger "remove", @_selected

  #
  # Handles click events for the entire list elements, including the list
  # container.
  #
  onMouseDown: (event) =>
    # Get the list item element
    element = if ($ event.target).is("li.list-view-item") then event.target else ($ event.target).parents("li.list-view-item") 

    # Clear the selection if the user clicks in the list container.
    @clearSelection() if @allowsDeselection and event.target.tagName == "UL"

    if event.metaKey
      model = ($ element).data("model")
      if model in @_selected.models
        @deselect element
      else
        @selectAnother element
      event.preventDefault()

    else if event.shiftKey
      element = event.target
      @expandSelectionToElement ($ element).parents("li.list-view-item") || element
      event.preventDefault()

  #
  # Handles focus events.
  #
  onFocus: (event) =>
    @focusedElement = $(event.target).closest("li.list-view-item")
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
      return @selectFirst() unless @_selected.length > 0

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
    return unless @allowsDragToReorder

    allowed = true

    # Ensure that the dragged item is a list view item...
    unless "application/x-list-view-item-id" in event.originalEvent.dataTransfer.types
      allowed = false

    # Ensure that the dragged item belongs to us...
    unless Cartilage.Views.ListView.draggedItem.model in @collection.models
      allowed = false

    event.preventDefault() if allowed

  onDrop: (event) =>
    return unless @allowsDragToReorder

    draggedElementId = event.originalEvent.dataTransfer.getData("application/x-list-view-item-id")
    draggedElement   = ($ "##{draggedElementId}")
    droppedElement   = ($ event.target).parents("li.list-view-item")[0] || ($ event.target)[0]

    # Ensure that the dragged element is not the same as the dropped element
    unless $(draggedElement)[0] is $(droppedElement)[0]
      if droppedElement and droppedElement.tagName is "LI"
        if event.originalEvent.offsetY < (($ droppedElement).height() / 2)
          ($ draggedElement).detach().insertBefore(droppedElement)
        else
          ($ draggedElement).detach().insertAfter(droppedElement)

    ($ droppedElement).removeClass("drop-before").removeClass("drop-after")

    # Clear the global draggedItem reference
    Cartilage.Views.ListView.draggedItem = false

  #
  # Moves the selection to the item visually above the selected item. If there
  # is no selection the first item will be selected.
  #
  moveSelectionUp: (e) =>
    element = ($ @focusedElement).prev "li.list-view-item"
    @select element if element.length > 0

  #
  # Moves the selection to the item visually below the selected item. If there
  # is no selection the first item will be selected.
  #
  moveSelectionDown: (e) =>
    element = ($ @focusedElement).next "li.list-view-item"
    @select element if element.length > 0

  #
  # Expands the selection downward from the currently selected element.
  #
  expandSelectionDown: (e) ->
    element = ($ @focusedElement).next "li.list-view-item"
    if element.length > 0
      @selectAnother element
      @focusedElement = ($ element).focus()

  #
  # Expands the selection upward from the currently selected element.
  #
  expandSelectionUp: (e) ->
    element = ($ @focusedElement).prev "li.list-view-item"
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
    elements = ($ @el).find("li.list-view-item").slice indexes...
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
  #   selectedItemTop     = @_selectedElement.offset().top - ($ scrollElement).offset().top
  #   selectedItemBottom  = selectedItemTop + @_selectedElement.innerHeight()
  #   selectedItemLeft    = @_selectedElement.offset().left - ($ scrollElement).offset().left
  #   selectedItemRight   = selectedItemLeft + @_selectedElement.innerWidth()
  #   currentScrollTop    = ($ scrollElement).scrollTop()
  #   currentScrollBottom = ($ scrollElement).scrollTop() + ($ scrollElement).innerHeight()
  #   currentScrollLeft   = ($ scrollElement).scrollLeft()
  #   currentScrollRight  = ($ scrollElement).scrollLeft() + ($ scrollElement).innerWidth()
  #   itemTopMargin       = parseInt(@_selectedElement.css("margin-top"), 10)
  #   itemBottomMargin    = parseInt(@_selectedElement.css("margin-bottom"), 10)
  #   itemLeftMargin      = parseInt(@_selectedElement.css("margin-left"), 10)
  #   itemRightMargin     = parseInt(@_selectedElement.css("margin-right"), 10)
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
