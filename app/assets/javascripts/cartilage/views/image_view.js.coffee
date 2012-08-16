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

class window.Cartilage.Views.ImageView extends Cartilage.View

  #
  # The URL to the image.
  #
  imageAddress: null

  #
  # Denotes whether or not the image has finished loading.
  #
  isLoaded: false

  #
  # Denotes whether or not an error occurred while loading.
  #
  isError: false

  #
  # Initializes a new instance of the split view. Pass firstView and
  # secondView as options, at a minimum, to specify the view setup.
  #
  initialize: (options = {}) ->
    @isLoaded     = false
    @imageElement = ($ "<img />").hide()
    @imageAddress = options["imageAddress"]
    ($ @imageElement).attr("src", @imageAddress) if @imageAddress?

  render: =>

    unless @isRendered

      # Add the Image Element
      ($ @el).html @imageElement

      # (Re-)bind to Events manually because event delegation will not work for
      # image load and error events...
      ($ @imageElement).load @handleLoadEvent
      ($ @imageElement).error @handleErrorEvent

      @isRendered = true

    # Update the Image Source
    unless @imageAddress == @imageElement.attr("src")
      @imageElement.attr("src", @imageAddress)

    @

  cleanup: ->
    @clear { silent: true }
    super()

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
    ($ @imageElement).off()
    @imageElement.hide().attr("src", null)
    @trigger "cleared" unless options["silent"]

  handleLoadEvent: (event) =>
    @isLoaded = true
    @isError = false
    @imageElement.fadeIn() unless @imageElement.is ":visible"
    @trigger "load", event

  handleErrorEvent: (event) =>
    @clear()
    @isError = true
    @trigger "error", event
