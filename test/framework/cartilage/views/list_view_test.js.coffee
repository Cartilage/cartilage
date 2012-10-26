module "Cartilage.Views.BasicListView"
  setup: ->
    testCollection = new Backbone.Collection([ {id: 1, name: "one"}, 
                                              {id: 2, name: "two"}, 
                                              {id: 3, name: "three"} ],
                                              model: Backbone.Model)

    @testListView = new Cartilage.Views.ListView
      collection: testCollection

test "should render collection correctly", 3, ->
  @testListView.prepare()
  $('#testElement').html @testListView.render().el 
  ok $('.list-view').length, "ListView container was created."
  equal $('.list-view-items-container > li').length, 3, "testListView should have 3 items."
  equal @testListView.selected.length, 0, "testListView should have 0 selected items."

asyncTest "should trigger select event for single-select ListView", 1, ->
  @testListView.prepare()
  $('#testElement').html @testListView.render().el 
  
  @testListView.on "select", ->
    ok true, "Select event should have been triggered."
    start()
  @testListView.selectFirst()

asyncTest "should trigger deselect event for single-select ListView", 1, ->
  @testListView.prepare()
  $('#testElement').html @testListView.render().el 
  
  @testListView.on "deselect", ->
    ok true, "Deselect event should have been triggered."
    start()
  @testListView.selectFirst()
  @testListView.deselect($('.list-view > ul.list-view-items-container > li').first())


module "Cartilage.Views.ListView.AllowsMultipleSelection"
  setup: ->
    @testListView = null
    testCollection = new Backbone.Collection([ {id: 1, name: "one"}, 
                                              {id: 2, name: "two"}, 
                                              {id: 3, name: "three"} ],
                                              model: Backbone.Model)

    @testListView = new Cartilage.Views.ListView
      collection: testCollection
      allowsMultipleSelection: yes

asyncTest "should trigger add event on @selected collection for multi-select ListView", 2, ->
  @testListView.prepare()
  $('#testElement').html @testListView.render().el 
  
  @testListView.selected.on "add", ->
    ok true, "add was called on multi-select"
    start()

  @testListView.selectFirst() #select($('.list-view > ul.list-view-items-container > li').first())
  equal @testListView.selected.length, 1, "One element should have been selected"

asyncTest "should trigger remove event on @selected collection for multi-select ListView", 3, ->
  @testListView.prepare()
  $('#testElement').html @testListView.render().el 
  
  @testListView.selected.on "remove", ->
    ok true, "remove was called on multi-select"
    start()

  @testListView.select($('.list-view > ul.list-view-items-container > li').first())
  @testListView.selectAnother($('.list-view > ul.list-view-items-container > li').last())
  equal @testListView.selected.length, 2, "Two elements should have been selected"
  @testListView.deselect($('.list-view > ul.list-view-items-container > li').first())
  equal @testListView.selected.length, 1, "Only one element should have been selected after deselect"

asyncTest "should trigger reset event on @selected collection for multi-select ListView", 3, ->
  @testListView.prepare()
  $('#testElement').html @testListView.render().el 
  
  @testListView.selected.on "reset", =>
    ok true, "reset was called"
    start()

  @testListView.select($('.list-view > ul.list-view-items-container > li').first())
  @testListView.selectAnother($('.list-view > ul.list-view-items-container > li').last())
  equal @testListView.selected.length, 2, "Two elements should have been selected"
  @testListView.clearSelection()
  equal @testListView.selected.length, 0, "No elements should have been selected"
