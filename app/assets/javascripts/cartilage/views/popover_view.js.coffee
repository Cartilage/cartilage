#
# Popover View
#

class window.Cartilage.Views.PopoverView extends Cartilage.View

  className: "popover-view"

  #
  # Aphid.UI.PopoverView#attachedView -> Aphid.UI.View | false
  #
  attachedView: false

  #
  # Aphid.UI.PopoverView#contentView -> Aphid.UI.View
  #
  contentElement: false

  #
  # Aphid.UI.PopoverView#position -> String
  #
  position: false

  #
  # Aphid.UI.PopoverView#triangleElement -> Element
  #
  triangleElement: false

  # --------------------------------------------------------------------------

  initialize: (options = {}) ->
    #     this.attachedView = false;
    #     this.position = "top";

    @triangleElement = ($ "<div class='triangle'/>")
    ($ @el).append @triangleElement

    @contentElement = ($ "<div class='content-view'/>")
    ($ @el).append @contentElement

  render: ->
    @calculatePosition()
    @

  calculatePosition: () ->
    return unless @attachedElement

    @resizeToFitContents()

    offset = ($ @attachedElement).offset()
    width  = ($ @attachedElement).outerWidth()
    height = ($ @attachedElement).outerHeight()
    top    = null
    left   = null

    switch @position

      when "top"
        top = offset.top - ($ @el).outerHeight(true)
        left = (offset.left + (width / 2)) - (($ @el).outerWidth(true) / 2)
        if offset.top - ($ @el).outerHeight(true) < 0
          top = offset.top + height
          @position = "bottom"

      when "bottom"
        top = offset.top + height
        left = (offset.left + (width / 2)) - (($ @el).outerWidth(true) / 2)
        maxHeight = ($ document).height()
        if offset.top + height + ($ @el).outerHeight(true) > maxHeight
          top = offset.top - ($ @el).outerHeight(true)
          @position = "top"

      when "left"
        top = (offset.top + (height / 2)) - (($ @el).outerHeight(true) / 2)
        left = offset.left - ($ @el).outerWidth(true)
        if offset.left - ($ @el).outerWidth(true) < 0
          left = offset.left + width
          @position = "right"

      when "right"
        top = (offset.top + (height / 2)) - (($ @el).outerHeight(true) / 2)
        left = offset.left + width
        maxWidth = ($ document).width()
        if offset.left + width + ($ @el).outerWidth(true) > maxWidth
          left = offset.left - ($ @el).outerWidth(true)
          @position = "left"

    ($ @el).removeClass("top")
    ($ @el).removeClass("right")
    ($ @el).removeClass("bottom")
    ($ @el).removeClass("left")
    ($ @el).addClass(@position)

    # Adjust for Screen
    # adjustment = 0
    # marginLeft = (($ @triangleElement).width() / 2) * -1
    #
    # if (left < 0)
    #   adjustment = (left * -1) * -1
    #   left = 0
    #
    # else if left > (($ document).width() - ($ @el).outerWidth(true))
    #   adjustment = left - (($ document).width() - ($ @el).outerWidth(true))
    #   left = (($ document).width() - ($ @el).outerWidth(true))
    #
    # console.log "Adjusting triangle position by " + (marginLeft + adjustment) + " pixels"
    #
    # ($ @triangleElement).css {
    #   marginLeft: "#{marginLeft + adjustment}px"
    # }

    ($ @el).css {
      top: "#{top}px",
      left: "#{left}px"
    }

  presentRelativeToElement: (element, position) ->
    @attachedElement = element
    @position = (position ?= "top")
    ($ @el).css { visibility: "hidden" }
    ($ @contentElement).children().css("display", "block")
    ($ document.body).append @render().el
    @calculatePosition()
    ($ @el).hide().css { visibility: "visible" }
    ($ @el).fadeIn()

    ($ document).unbind("click", @handleDocumentClickEvent).click @handleDocumentClickEvent

  resizeToFitContents: ->
    element = ($ @contentElement).children()[0]
    width = ($ element).outerWidth()
    height = ($ element).outerHeight()

    ($ @contentElement).css {
      width: "#{width}px",
      height: "#{height}px"
    }

    ($ @el).css {
      width: "#{width}px",
      height: "#{height}px"
    }

  handleDocumentClickEvent: (event) =>

    return if event.target == @attachedElement

    ($ document).unbind("click", @handleDocumentClickEvent)

    ($ @el).fadeOut "fast", =>
      ($ @el).remove()

#   // Event Handlers ----------------------------------------------------------
#
#   _startObserving: function($super)
#   {
#     $super();
#
#     // Document Click Events
#     if (this.handleDocumentClickEvent && !this._handleDocumentClickEventListener)
#     {
#       $L.debug("Observing for Document Click Events", this);
#       this._handleDocumentClickEventListener = this.handleDocumentClickEvent.bindAsEventListener(this);
#       Event.observe(document, "click", this._handleDocumentClickEventListener);
#     }
#   },
#
#   _stopObserving: function($super)
#   {
#     $super();
#
#     // Document Click Events
#     if (this._handleDocumentClickEventListener)
#     {
#       Event.stopObserving(document, "click", this._handleDocumentClickEventListener);
#       this._handleDocumentClickEventListener = false;
#     }
#
#     // Handle Scroll Notifications
#     this.addObserver(this.handleViewDidScrollNotification, "ViewDidScrollNotification");
#   },
#
#   handleDocumentClickEvent: function(event)
#   {
#     var element = event.element();
#
#     // Ignore Clicks in PopoverView
#     if (element == this.get("element") || (element != this.get("element") && element.descendantOf(this.get("element"))))
#       return;
#
#     // Ignore clicks in Attached View
#     if (this.get("attachedView") && (element == this.get("attachedView.element") || (element != this.get("attachedView.element") && element.descendantOf(this.get("attachedView.element")))))
#       return;
#
#     $L.info("handleDocumentClickEvent", this);
#
#     this.removeFromSuperviewAnimated();
#   },
#
#   handleViewDidScrollNotification: function(view)
#   {
#     if (this.get("superview"))
#       this.calculatePosition();
#   }
#
# });
