#
# Modal View
#
# This is a thin wrapper around Bootstrap's Modal plugin that allows you
# to contain your modal view logic in its own class.
#

class window.Cartilage.Views.ModalView extends Cartilage.View

  className: "modal-view modal fade"

  render: ->
    ($ @el).html @template { model: @model }
    @

  show: ->
    ($ document.body).append @render().el
    ($ @el).modal('show')
    ($ @el).on 'hidden', @cleanup

  hide: =>
    ($ @el).modal('hide')

  cleanup: =>
    ($ @el).off 'hidden'
    super()
