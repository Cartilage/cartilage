
# Cartilage Release History

## Version 0.9.5 — Not Yet Released

 * [Cartilage.Views.ListView] Implemented allowsSelection option for enabling
   or disabling list view selection (which is enabled by default).

 * [Cartilage.Views.ListView] Added a ListViewItem class that all items should
   derive from and converted ListView to use the new view lifecycle methods.

 * [Cartilage.Views.SplitView] Added support for drag-resizing split views,
   which is enabled by default and can be controlled via the isResizable
   property.

 * [Cartilage.Views.SourceListView] Added support for specifying (optional)
   header and footer views.

 * [Cartilage.View] The @collection and @model attributes are now exposed to
   the template automatically (unless you've overridden the render method) as
   the camelized collection or model class name.

 * [Extensions] Added _.camelize for converting titlecase, underscored or
   dasherized values to camel-case.

 * [Cartilage.View] Added support for specifying the container element that
   the subview will be inserted into.

 * [Cartilage.Application] Fixed support for passing absolute URLs through to
   the browser.

 * [Cartilage.Application] Added support for passing through relative URLs to
   the backend application when the link element contains the data attribute
   data-passthrough="true".

 * [Cartilage.Model] Added as a new base model class to be used by all
   Cartilage-based applications.

 * [Cartilage.Views.LoadingIndicatorView] Now automatically derives the bar
   color from CSS, if specified as the "color" property.

 * [Cartilage.Views.LoadingIndicatorView] Automatically start and stop the
   indicator animation when added as a subview.

 * [Cartilage.Application] Added as a new base class to be used by all
   Cartilage-based applications.

 * [Cartilage.View] Added basic view lifecycle management through the
   addSubview and removeFromSuperview methods.

 * [Extensions] Added 3 new methods to Underscore: dasherize, underscore and
   remove.

 * [CallConduit.Views.ListView] Implemented support for restoring the selected
   state of a list view when its collection is reset or otherwise changed.

 * [CallConduit.Views.ListView] Fixed a rather glaring issue wherein the
   selected state of list views was shared across instances.

 * [CallConduit.Views.SplitView] Added setFirstView and setSecondView methods
   for replacing the views without a full re-rendering of the split view
   instance.

 * [Cartilage.View] Introduced View#observe for binding event observers to
   the current view (to be used in place of Object#on). Observed events will
   automatically be cleaned up when the view is removed.

 * [Cartilage.View] Renamed View#dismiss to View#cleanup. This method should
   be overridden in subclasses, where necessary, to perform any view cleanup
   when the view is removed. It should be called whenever you are manually
   removing a view, in place of View#remove.

 * [Cartilage.Views.SourceListView] Added SourceListView for use as sidebars
   with some default styling.

 * [Cartilage.Views.MatrixView] Allow drag-selection to be enabled/disabled by
   setting the allowsDragSelection property. Defaults to false.

 * [Cartilage.Views.MatrixView] Hide the overlay when rendering to prevent a
   1x1 pixel artifact being visible.

 * [Cartilage.Views.MatrixView] Only begin drag operations on left mouse
   button clicks.

 * [Cartilage.Views.ModalView] Made the modal view class responsible for
   display in addition to dismissal, preventing more than one instance from
   being displayed at once.

 * [Cartilage.Views.ListView] Fixed an issue when expanding selection to
   another element in the list (or matrix).

 * [Cartilage.Views.SplitView] Added support for redrawing the view when the
   window is resized.

 * Initial port of Aphid to Backbone.js and Bootstrap.
