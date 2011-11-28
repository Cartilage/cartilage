#
# Image View
#
# Wraps an HTML <img/> element and observes for load and error events,
# dispatching those events to callbacks defined on a subclass or methods on
# the delegate.
#
# Events
# ------
#
#  * "loaded"
#  * "error"
#  * "cleared"
#

class window.Cartilage.Views.ImageView extends Backbone.View

  className: "image-view"

  #
  # The URL to the image.
  #
  imageAddress: null

  #
  # Denotes whether or not the image has finished loading.
  #
  isLoaded: false

  #
  # Initializes a new instance of the split view. Pass firstView and
  # secondView as options, at a minimum, to specify the view setup.
  #
  initialize: (options = {}) ->
    @isLoaded     = false
    @imageElement = ($ "<img />").hide()
    @imageAddress = options["imageAddress"]
    ($ @imageElement).attr("src", @imageAddress) if @imageAddress?

  render: ->

    # Add the Image Element
    ($ @el).html @imageElement

    # (Re-)bind to Events manually because event delegation will not work for
    # image load and error events...
    ($ @imageElement).load @handleLoadEvent
    ($ @imageElement).error @handleErrorEvent

    # Update the Image Source
    @imageElement.attr("src", @imageAddress) if @imageAddress?

    @

  #
  # Sets the image to that which is specified by URL. This causes a render to
  # take place.
  #
  setImage: (url) ->
    @imageAddress = url
    @render()

  clear: (options = {}) ->
    @isLoaded = false
    @imageAddress = null
    @imageElement.hide().attr("src", null)
    @trigger "cleared" unless options["silent"]

  handleLoadEvent: (event) =>
    @isLoaded = true
    @imageElement.fadeIn() unless @imageElement.is ":visible"
    @trigger "load", event

  handleErrorEvent: (event) =>
    @clear()
    @trigger "error", event
