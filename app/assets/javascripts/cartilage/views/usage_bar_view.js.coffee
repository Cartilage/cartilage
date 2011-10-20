#
# Usage Bar View
#

class window.Aphid.Views.UsageBarView extends Backbone.View

  className: "usage-bar-view"

  colors: [ '#6ba2d4', '#a765a2', '#f69062', '#8ccc64', '#c26bb4', '#e9d243' ]

  value: null
  segments: null
  barView: null

  #
  # Initialization
  #
  initialize: (options = {}) ->

    # Apply options
    @colors = options["colors"] if options["colors"]?
    @segments = options["segments"] || (@segments ?= [])

    @barView = new Aphid.Views.BarView

  render: ->

    # Render the Bar View
    @barView.segments.reset @segments
    @barView.colors = @colors
    ($ @el).html @barView.render().el

    @
