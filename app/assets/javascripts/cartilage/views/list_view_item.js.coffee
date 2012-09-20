#
# List View Item
#

class window.Cartilage.Views.ListViewItem extends Cartilage.View

  # View Configuration -------------------------------------------------------

  id: -> # TODO Hacky
    "list-view-item-#{Math.floor(Math.random() * 1000000000)}"

  tagName: "li"

  events:
    "dragover": "onDragOver"
    "dragleave": "onDragLeave"
    "dragstart": "onDragStart"

  # Properties ---------------------------------------------------------------

  #
  # The list view instance that the list view item currently belongs to.
  #
  @property "listView", access: READONLY

  #
  # Whether or not the list view item is currently selected.
  #
  @property "isSelected", access: READONLY, default: no

  # Internal Properties ------------------------------------------------------

  # --------------------------------------------------------------------------

  initialize: (options = {}) ->

    # Initialize the View
    super(options)

    # Give the Element a tab index so that it can be focused
    ($ @el).attr "tabindex", 0

    # Assign the Model to the Element
    ($ @el).data "model", @model

    # Assign the List View Item to the Element
    ($ @el).data "view", @

  prepare: ->

    # Prepare the View
    super()

    # Enable dragging, if configured
    if @listView and @listView.allowsDragToReorder
      ($ @el).attr "draggable", true

  onDragLeave: (event) =>
    return unless @listView.allowsDragToReorder
    ($ @el).removeClass("drop-before").removeClass("drop-after")

  onDragStart: (event) =>
    return unless @listView.allowsDragToReorder
    event.originalEvent.dataTransfer.setData("application/x-list-view-item-id", ($ @el).attr("id"))
    Cartilage.Views.ListView.draggedItem = @

  onDragOver: (event) =>
    return unless @listView.allowsDragToReorder
    allowed = true

    # Ensure that the dragged item is a list view item...
    unless "application/x-list-view-item-id" in event.originalEvent.dataTransfer.types
      allowed = false

    # Ensure that the dragged item belongs to us...
    unless Cartilage.Views.ListView.draggedItem.model in @listView.collection.models
      allowed = false

    if allowed
      if event.originalEvent.offsetY < (($ @el).height() / 2)
        ($ @el).removeClass("drop-after").addClass("drop-before")
      else
        ($ @el).removeClass("drop-before").addClass("drop-after")
