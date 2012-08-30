
class window.Cartilage.Views.ListViewItem extends Cartilage.View

  tagName: "li"

  id: -> # TODO Hacky
    "list-view-item-#{Math.floor(Math.random() * 1000000000)}"

  events:
    "dragenter": "onDragEnter"
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
    ($ @el).attr "draggable", true
    ($ @el).data "model", @model
    ($ @el).data "view", @
    super()

  onDragEnter: (event) =>
    # TODO check the parent listView for drag support
    # console.log "listItem.dragEnter"
    # return if @dragOver
    #   @dragOver = true

  onDragLeave: (event) =>
    ($ @el).removeClass("drop-before").removeClass("drop-after")

  onDragStart: (event) =>
    event.dataTransfer.setData("application/x-list-view-item-id", ($ @el).attr("id"))
    # console.log "I belong to listView:", @listView
    Cartilage.Views.ListView.draggedItem = @

  onDragOver: (event) =>
    allowed = true

    # Ensure that the list item belongs to us...
    unless "application/x-list-view-item-id" in event.dataTransfer.types
      # console.log "Item not of the right type"
      allowed = false

    unless Cartilage.Views.ListView.draggedItem.model in @listView.collection.models
      # console.log "Item not in listView collection", @collection.models, Cartilage.Views.ListView.draggedItem
      allowed = false

    if allowed
      if event.originalEvent.offsetY < (($ @el).height() / 2)
        ($ @el).removeClass("drop-after").addClass("drop-before")
      else
        ($ @el).removeClass("drop-before").addClass("drop-after")
