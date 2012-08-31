
class window.Cartilage.Views.ListViewItem extends Cartilage.View

  tagName: "li"

  id: -> # TODO Hacky
    "list-view-item-#{Math.floor(Math.random() * 1000000000)}"

  events:
    "dragover": "onDragOver"
    "dragleave": "onDragLeave"
    "dragstart": "onDragStart"

  #
  # The parent ListView instance that this item belongs to.
  #
  listView: null

  initialize: (options = {}) ->

    # Apply options
    @listView = options["listView"]

    super(options)

  render: ->
    ($ @el).attr "tabindex", 0
    ($ @el).data "model", @model
    ($ @el).data "view", @
    if @listView and @listView.allowsDragToReorder
      ($ @el).attr "draggable", true
    super()

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
