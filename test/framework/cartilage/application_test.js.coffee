
module "Cartilage.Application"

test "should initialize and launch application", ->
  class TestApplication extends Cartilage.Application
    initialize: ->
      new Backbone.Router
        routes:
          "": "showMainView"
        showMainView: ->
          "mainView"
      Backbone.history.start({ pushState: true })
  TestApplication.launch()
  ok not _.isNull(TestApplication.sharedInstance), "sharedInstance should not be null"
