#
# Modal View
#

class window.Cartilage.Views.ModalView extends Backbone.View

  className: "modal modal-view"

  events:
    "click .close": "dismiss"

  render: ->
    @overlayElement = ($ "<div class='overlay'></div>")
    ($ document.body).append @overlayElement
    ($ @el).html @template { model: @model }
    @

  dismiss: ->
    ($ @el).remove()
    ($ @overlayElement).remove()
