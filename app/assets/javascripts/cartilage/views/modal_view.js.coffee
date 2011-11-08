#
# Modal View
#

class window.Cartilage.Views.ModalView extends Backbone.View

  className: "modal modal-view"

  events:
    "click .close": "dismiss"

  isVisible: false

  render: ->
    @overlayElement = ($ "<div class='modal-overlay'></div>")
    ($ document.body).append @overlayElement
    ($ @el).html @template { model: @model }
    @delegateEvents()
    @

  display: ->
    return unless not @isVisible
    @isVisible = true
    ($ document.body).append @render().el

  dismiss: =>
    return unless @isVisible
    ($ @el).remove()
    ($ @overlayElement).remove()
    @isVisible = false
