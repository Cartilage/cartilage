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
  @property "imageAddress", set: (url) ->
    @_imageAddress = url
    @_imageElement = ($ "<img />").attr('src', @imageAddress)
  
  #
  # Denotes whether or not the image has finished loading.
  #
  @property "isLoaded", access: READONLY, default: no

  #
  # Denotes whether or not an error occurred while loading.
  #
  @property "isError", access: READONLY, default: no

  #
  # The image element that this view manages.
  #
  @property "imageElement", access: READONLY

  # --------------------------------------------------------------------------

  initialize: (options = {}) ->

    # Initialize the View
    super(options)

    # Bind to Events manually because event delegation will not work for
    # image load and error events...
    ($ @imageElement).load @handleLoadEvent
    ($ @imageElement).error @handleErrorEvent

  render: ->
    super()
    ($ @el).html @_imageElement

    @

  cleanup: ->
    @clear { silent: true }
    super()

  clear: (options = {}) ->
    @_isLoaded = false
    @_imageAddress = null
    ($ @_imageElement).off().hide().attr("src", null)
    @trigger "cleared" unless options.silent

  # Event Handlers -----------------------------------------------------------

  handleLoadEvent: (event) =>
    @_isLoaded = true
    @_isError = false
    @imageElement.fadeIn() unless @imageElement.is ":visible"
    @trigger "load", event

  handleErrorEvent: (event) =>
    @clear()
    @_isError = true
    @trigger "error", event
