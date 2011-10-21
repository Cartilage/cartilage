#
# Bar Segment View
#

class window.Cartilage.Views.BarSegmentView extends Backbone.View

  tagName: "li"
  className: "bar-segment-view"

  #
  # The BarView instance that this segment belongs to.
  #
  barView: null

  #
  # The background color of the segment.
  #
  color: null

  # The fill width specified as a float from 0 to 1 that represents the
  # percentage of the segment to occupy.
  #
  fillWidth: null

  #
  # The width specified as a float from 0 to 1 that represents the percentage
  # of the barView to occupy.
  #
  width: null

  initialize: (options = {}) ->
    @barView   = options["barView"]
    @color     = (options["color"] || @color ?= "#eee")
    @width     = (options["width"] || @width ?= 0)
    @fillWidth = (options["fillWidth"] || @fillWidth ?= 0)

  render: ->

    # Bar Element
    barElement = ($ "<div />").addClass("bar")
    ($ barElement).css {
      width: (@fillWidth * 100) + "%",
      backgroundColor: @color
    }
    ($ barElement).css { display: "block" } if @fillWidth > 0
    ($ @el).html barElement

    ($ @el).css {
      width: (@width * 100) + "%"
    }

    @
