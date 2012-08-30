#
# Cartilage "Base" View
#

class window.Cartilage.View extends Backbone.View

  superview: null
  subviews: []
  observers: []

  template: (options) ->
    try
      if JST[_.underscore(@constructor.name)]
        JST[_.underscore(@constructor.name)](options)
    catch error
      if console
        console.warn "Template error in #{_.underscore(@constructor.name)}.jst.ejs: \"#{error.message}\"", error

  prepare: ->

    # Empty implementation

  render: ->

    # Determine CSS class names from the view class hierarchy and any other
    # custom classes defined by a subclass.
    ($ @el).addClass @determineClassName()

    # Automatically assign collections and models to the template, as their
    # respective class names.
    @templateVariables ?= {}
    if @collection
      @templateVariables[_.camelize(@collection.constructor.name)] = @collection
    if @model
      @templateVariables[_.camelize(@model.constructor.name)] = @model
    ($ @el).html @template(@templateVariables)

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

    # Don't allow nil objects to be passed...
    return unless view

    # Maintain a reference to the added subview for later cleanup, or other
    # operations
    @subviews.push(view)

    # Set a reference to this view as the added view's superview
    view.superview = @

    # Render the View, if necessary
    unless view.isRendered
      view.render()
      view.isRendered = true
      view.trigger("rendered")

    # Make the View's Element invisible
    ($ view.el).css("visibility", "hidden").show()

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
        ($ @el).detach()

    else
      ($ @el).hide()
      @trigger("removed")
      ($ @el).detach()

    # Remove the reference to this view from its superview's subviews
    # array
    _.remove @superview.subviews, @

    # Clear the superview reference
    @superview = null

  removeFromSuperviewAnimated: ->
    @removeFromSuperview(true)

  determineClassName: ->
    classNames = [ _.dasherize(@constructor.name) ]

    # Get class names for each view in the class heirarchy
    superklass = @constructor.__super__
    while superklass
      classNames.push _.dasherize(superklass.constructor.name)
      superklass = superklass.constructor.__super__

    # Reverse the order of the class names
    classNames = classNames.reverse()

    # Merge in custom class name(s)
    if _.isFunction(@className)
      classNames.push @className().split(" ")
    else if @className
      classNames.push @className.split(" ")

    # Flatten the Array
    classNames = _.flatten(classNames)

    # Compact the Array to remove any empty values
    classNames = _.compact(classNames)

    # Remove any duplicate class names
    classNames = _.unique(classNames)

    # Convert the class names array to a string
    classNames.join(" ")
