#
# Cartilage "Base" View
#

class window.Cartilage.View extends Backbone.View

  className: "view"

  cleanup: ->
    @off()
    @remove()
