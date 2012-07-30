
class window.Cartilage.Application

  @Collections: {}
  @Models: {}
  @Routers: {}
  @Views: {}

  @sharedInstance: null

  @launch: ->
    @sharedInstance = new @
    @sharedInstance.initialize()
    @hijackLinks()

  @hijackLinks: ->
    if Backbone.history and Backbone.history._hasPushState
      $(document).delegate "a", "click", (event) ->
        href = $(this).attr("href")
        protocol = this.protocol + "//"

        # Ensure the protocol is not part of URL, meaning its relative.
        # Stop the event bubbling to ensure the link will not cause a page refresh.
        if href.slice(protocol.length) != protocol
          event.preventDefault()

          # Note by using Backbone.history.navigate, router events will not be
          # triggered.  If this is a problem, change this to navigate on your
          # router.
          Backbone.history.navigate(href, true)
