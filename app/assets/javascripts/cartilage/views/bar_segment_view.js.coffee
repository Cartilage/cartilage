#
# Bar Segment View
#

class window.Cartilage.Views.BarSegmentView extends Cartilage.View

  # View Configuration -------------------------------------------------------

  tagName: "li"

  # Properties ---------------------------------------------------------------

  #
  # The BarView instance that this segment belongs to.
  #
  @property "barView", access: READONLY

  #
  # The background color of the segment.
  #
  @property "color", default: "#eeeeee"

  #
  # The fill width specified as a float from 0 to 1 that represents the
  # percentage of the segment to occupy.
  #
  @property "fillWidth", default: 0

  #
  # The width specified as a float from 0 to 1 that represents the percentage
  # of the barView to occupy.
  #
  @property "width", default: 0

  # Internal Properties ------------------------------------------------------

  # --------------------------------------------------------------------------

  initialize: (options = {}) ->

    # Initialize the View
    super(options)

    # Initialize the Bar Element
    @_barElement = ($ "<div />").addClass("bar")
    ($ @_barElement).css
      width: (@fillWidth * 100) + "%"
      backgroundColor: @color

  prepare: ->

    # Prepare the View
    super()

    ($ @el).html @_barElement
    ($ @_barElement).css { display: "block" } if @fillWidth > 0

    ($ @el).css { width: (@width * 100) + "%" }
