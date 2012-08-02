#
# Cartilage "Base" View
#

class window.Cartilage.View extends Backbone.View

  superview: null
  subviews: []
  observers: []

  className: ->
    [ "view", _.dasherize(@constructor.name) ].join(" ")

  template: (options) ->
    JST[_.underscore(@constructor.name)](options)

  render: ->
    templateOptions = {}

    if @collection
      templateOptions[_.camelize(@collection.constructor.name)] = @collection
    if @model
      templateOptions[_.camelize(@model.constructor.name)] = @model

    ($ @el).html @template(templateOptions)
    @

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

  addSubview: (view, container = @el, animated = false) ->

    # Maintain a reference to the added subview for later cleanup, or other
    # operations
    @subviews.push(view)

    # Set a reference to this view as the added view's superview
    view.superview = @

    # Render the View
    view.render()

    # Make the View's Element invisible
    ($ view.el).css("visibility", "hidden")

    # Add the View's Element to the DOM
    ($ container).append(view.el)

    # Prepare the View for display, if necessary
    unless view.isPrepared
      view.prepare() if view.prepare
      view.isPrepared = true
      view.trigger("prepared")

    # Trigger the "willPresent" event so that views have a chance to
    # manipulate their state before being presented to the user
    view.trigger("willPresent")

    # Make the View's Element visible and trigger the "presented" event so
    # views have a chance to manipulate their state after being presented
    # to the user
    if animated
      ($ view.el).hide()
      ($ view.el).css("visibility", "visible")
      ($ view.el).fadeIn 750, -> view.trigger("presented")

    else
      ($ view.el).css("visibility", "visible")
      view.trigger("presented")

  addSubviewAnimated: (view, container = @el) ->
    @addSubview(view, container, true)

  removeFromSuperview: (animated = false) ->

    # Trigger the "willRemove" event so that views have a chance to
    # manipulate their state before being removed from view
    @trigger("willRemove")

    # Remove observers for all DOM events
    @off()

    # Remove all other event observers
    @removeObservers()

    # Remove the View's Element from the DOM and trigger the "removed" event
    # so views have a chance to manipulate their state after being removed
    if animated
      ($ @el).fadeOut 750, =>
        @trigger("removed")
        @remove()

    else
      ($ @el).hide()
      @trigger("removed")
      @remove()

    # Remove the reference to this view from its superview's subviews
    # array
    _.remove @superview.subviews, @

    # Clear the superview reference
    @superview = null

  removeFromSuperviewAnimated: ->
    @removeFromSuperview(true)
