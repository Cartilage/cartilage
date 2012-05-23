#
# View
#

class window.Cartilage.View extends Backbone.View

  className: "view"

  dismiss: ->
    @remove()
    @unbind()
