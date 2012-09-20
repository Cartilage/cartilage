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

  # Properties ---------------------------------------------------------------

  #
  # The URL to the image.
  #
  @property "imageAddress"

  #
  # Denotes whether or not the image has finished loading.
  #
  @property "isLoaded", access: READONLY, default: no

  #
  # Denotes whether or not an error occurred while loading.
  #
  @property "isError", access: READONLY, default: no

  # Internal Properties ------------------------------------------------------

  # --------------------------------------------------------------------------

  initialize: (options = {}) ->

    # Initialize the View
    super(options)

    # Initialize Image Element
    ($ @el).html @_imageElement = @make "img"
    ($ @_imageElement).hide()

    # (Re-)bind to Events manually because event delegation will not work for
    # image load and error events...
    ($ @_imageElement).load @handleLoadEvent
    ($ @_imageElement).error @handleErrorEvent

  prepare: ->

    # Prepare the View
    super()

    # Set Image Source
    ($ @_imageElement).attr("src", @imageAddress) if @imageAddress?

  cleanup: ->
    @clear { silent: true }
    super()

  #
  # Sets the image to that which is specified by URL.
  #
  setImage: (url) ->
    @imageAddress = url
    ($ @_imageElement).attr("src", @imageAddress)

  clear: (options = {}) ->
    @isLoaded = false
    @imageAddress = null
    ($ @_imageElement).off().hide().attr("src", null)
    @trigger "cleared" unless options.silent

  # Event Handlers -----------------------------------------------------------

  handleLoadEvent: (event) =>
    @isLoaded = true
    @isError = false
    @_imageElement.fadeIn() unless @_imageElement.is ":visible"
    @trigger "load", event

  handleErrorEvent: (event) =>
    @clear()
    @isError = true
    @trigger "error", event
