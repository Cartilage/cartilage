
# Cartilage Release History

## Version 0.9.5 — Not Yet Released

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
