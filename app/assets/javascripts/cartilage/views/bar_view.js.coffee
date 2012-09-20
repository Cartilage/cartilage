#
# Bar View
#

class window.Cartilage.Views.BarView extends Cartilage.View

  # View Configuration -------------------------------------------------------

  tagName: "ul"

  # Properties ---------------------------------------------------------------

  #
  # The segments of the bar view.
  #
  @property "segments", default: new Cartilage.Collections.Segments

  #
  # The value of the bar view.
  #
  @property "value", default: 0

  #
  # The default colors for the segments that comprise the bar view.
  #
  @property "colors", default: [ '#6ba2d4', '#a765a2', '#f69062', '#8ccc64', '#c26bb4', '#e9d243' ]

  # Internal Properties ------------------------------------------------------

  _cumulativeWidth: 0

  # --------------------------------------------------------------------------

  prepare: ->

    # Prepare the View
    super()

    # Create segment views for each segment of the bar view.
    _.each @segments.models, (segment, index) =>
      segmentWidth = @_percentageWidthForSegmentAtIndex(index)
      barWidth     = @_percentageWidthForBarInSegmentAtIndex(index)
      segmentView  = new Cartilage.Views.BarSegmentView {
        barView: @,
        model: segment,
        width: segmentWidth,
        fillWidth: barWidth,
        color: @colors[index]
      }
      @addSubview segmentView

  # TODO Move this to BarSegmentView
  _percentageWidthForSegmentAtIndex: (index) =>
    segment       = @segments.models[index]
    segmentWidth  = segment.get("maximum") - @segments.models[index - 1]?.get("maximum") || segment.get("maximum")
    totalWidth    = _.last(@segments.models).get("maximum")
    computedWidth = segmentWidth / totalWidth

    computedWidth = 0.02 unless computedWidth > 0.02
    computedWidth = 1.0 - @_cumulativeWidth unless @segments.models[index + 1]?

    @_cumulativeWidth += computedWidth

    # console.log "Segment: ", segment, "Width: ", segmentWidth, "Computed Width: ", computedWidth, "Total Width: ", totalWidth, "Cumulative Width: ", @_cumulativeWidth

    computedWidth

  # TODO Move this to BarSegmentView
  _percentageWidthForBarInSegmentAtIndex: (index) ->
    segment      = @segments.models[index]
    segmentWidth = segment.get("maximum") - @segments.models[index - 1]?.get("maximum") || segment.get("maximum")
    fooWidth     = @value - _.sum(_.map(@segments.models.slice(0, index), (segment) -> segment.get("maximum")))
    barWidth     = 0

    return 0 if fooWidth <= 0

    if @value > segment.get("maximum")
      barWidth = 1.0
    else
      barWidth = fooWidth / segmentWidth

    # console.log "Bar for Segment: ", segment, "Width: ", segmentWidth, "Bar Width: ", barWidth, "Value: ", @value, "Foo Width: ", fooWidth

    barWidth
