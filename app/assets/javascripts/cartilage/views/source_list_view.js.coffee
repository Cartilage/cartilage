#
# Source List View
#

class window.Cartilage.Views.SourceListView extends Cartilage.View

  #
  # An optional header view...
  #
  headerView: null
  headerViewContainer: null

  #
  # The managed list view.
  #
  listView: null
  itemView: null

  #
  # An optional toolbar view that is displayed in the footer.
  #
  footerView: null
  footerViewContainer: null

  initialize: (options = {}) ->

    # Apply options
    @headerView = options["headerView"]
    @listView   = options["listView"]
    @itemView   = options["itemView"]
    @footerView = options["footerView"]

    if @headerView
      @headerViewContainer = @make("div", { class: "header-view" })
      ($ @el).append(@headerViewContainer)

    @listView ?= new Cartilage.Views.ListView
      collection: @collection
      itemView: @itemView

    if @footerView
      @footerViewContainer = @make("div", { class: "footer-view" })
      ($ @el).append(@footerViewContainer)

  prepare: ->

    @addSubview @listView

    if @headerView
      @addSubview @headerView, @headerViewContainer
      ($ @listView.el).css("top", ($ @headerView.el).outerHeight())
      ($ @headerViewContainer).css("height", ($ @headerView.el).outerHeight())

    if @footerView
      @addSubview @footerView, @footerViewContainer
      ($ @listView.el).css("bottom", ($ @footerView.el).outerHeight())
      ($ @footerViewContainer).css("height", ($ @footerView.el).outerHeight())
