#
# Source List View
#
# As the name implies, the source list view is a subclass of ListView that
# attempts to emulate the common source list master/detail pattern. It applies
# some default styling to the list view and allows for header and footer views
# to be used.
#

#= require cartilage/views/source_list_view_item

class window.Cartilage.Views.SourceListView extends Cartilage.Views.ListView

  # Properties ---------------------------------------------------------------

  #
  # If defined, displays the specified view above the list view. Dimensions of
  # the view are automatically determined, so be sure that the passed view has
  # height or is relatively positioned so that height may be determined.
  #
  @property "headerView"

  #
  # If defined, displays the specified view below the list view. Dimensions of
  # the view are automatically determined, so be sure that the passed view has
  # height or is relatively positioned so that height may be determined.
  #
  @property "footerView"

  #
  # Override the default itemView to SourceListViewItem.
  #
  @property "itemView", default: Cartilage.Views.SourceListViewItem

  # Internal Properties ------------------------------------------------------

  # --------------------------------------------------------------------------

  initialize: (options = {}) ->

    # Initialize the List View
    super(options)

    # Initialize Header View Container
    if @headerView
      ($ @el).append @_headerViewContainer = @make "div",
        class: "header-view"

    # Initialize Footer View Container
    if @footerView
      ($ @el).append @_footerViewContainer = @make "div",
        class: "footer-view"

  prepare: ->

    # Prepare the List View
    super()

    # Add the header view as a subview and reposition the list view to account
    # for the height of the header view.
    if @headerView
      @addSubview @headerView, @_headerViewContainer
      ($ @_listViewItemsContainer).css("top", ($ @headerView.el).outerHeight())
      ($ @_headerViewContainer).css("height", ($ @headerView.el).outerHeight())

    # Add the footer view as a subview and reposition the list view to account
    # for the height of the footer view.
    if @footerView
      @addSubview @footerView, @_footerViewContainer
      ($ @_listViewItemsContainer).css("bottom", ($ @footerView.el).outerHeight())
      ($ @_footerViewContainer).css("height", ($ @footerView.el).outerHeight())
