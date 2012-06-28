#
# Cartilage "Base" View
#

class window.Cartilage.View extends Backbone.View

  className: "view"

  observers: []

  cleanup: ->
    @off()
    @removeObservers()
    @remove()

  observe: (source, event, callback) ->
    source.on(event, callback, @)
    @observers.push { source: source, event: event, callback: callback }

  removeObservers: ->
    _.each @observers, (observer) ->
      observer.source.off(observer.event, observer.callback, @)
    @observers = []
