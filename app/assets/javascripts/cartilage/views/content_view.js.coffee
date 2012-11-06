class window.Cartilage.Views.ContentView extends Cartilage.View

  el: "#content"

  initialize: (options = {}) ->
    @currentView = null
    super(options)

  show: (view) ->
    if @currentView 
      @currentView.cleanup() if @currentView.cleanup
    else if @currentView
      console.warn "This view does not implement a cleanup method. Please extend all of your views from Cartilage.View to ensure compatibility."

    @currentView = view
    @addSubview @currentView
