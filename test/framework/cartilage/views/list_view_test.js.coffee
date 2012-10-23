
module "Cartilage.Views.ListView"

  setup: ->
    class window.aModel extends Backbone.Model
    class window.aCollection extends Backbone.Collection
    window.testCollection = new aCollection([ {id: 1, name: "one"}, 
                                              {id: 2, name: "two"}, 
                                              {id: 3, name: "three"} ],
                                              model: aModel )
  teardown: ->
    # Have to unbind all the events here. Just nulling the objects still leaves the events bound.
    window.testListView.off()
    window.testListView.selected.off()
    window.testListView = null
    window.testCollection = null

test "should render collection correctly", ->
  expect(3)
  window.testListView = new Cartilage.Views.ListView(collection: testCollection, el: ($ '#testElement'))
  testListView.prepare()
  ok $('#testElement > ul'), "ListView container was not created."
  equal $('#testElement > ul > li').length, 3, "testListView should have 3 items."
  equal testListView.selected.length, 0, "testListView should have 0 selected items."

asyncTest "should trigger select event for single-select ListView", ->
  expect(1)
  window.testListView = new Cartilage.Views.ListView(collection: testCollection, el: ($ '#testElement'))
  testListView.prepare()
  testListView.on "select", ->
    ok true, "Select event should have been triggered."
    start()
  testListView.select($('#testElement > ul > li').first())

asyncTest "should trigger deselect event for single-select ListView", ->
  expect(1)
  window.testListView = new Cartilage.Views.ListView(collection: testCollection, el: ($ '#testElement'))
  testListView.prepare()
  testListView.on "deselect", ->
    ok true, "Deselect event should have been triggered."
    start()
  testListView.select($('#testElement > ul > li').first())
  testListView.deselect($('#testElement > ul > li').first())

asyncTest "should trigger add event on @selected collection for multi-select ListView", 2, ->
  window.testListView = new Cartilage.Views.ListView(collection: testCollection, el: ($ '#testElement'), allowsMultipleSelection: yes)
  testListView.prepare()
  testListView.selected.on "add", =>
    ok true, "Add event should have been triggered."
    start()
  testListView.select($('#testElement > ul > li').first())
  equal testListView.selected.length, 1, "One element should have been selected"

asyncTest "should trigger remove event on @selected collection for multi-select ListView", 3, ->
  window.testListView = new Cartilage.Views.ListView(collection: testCollection, el: ($ '#testElement'), allowsMultipleSelection: yes)
  testListView.prepare()
  testListView.selected.on "remove", ->
    ok true, "Remove event should have been triggered."
    start()
  testListView.select($('#testElement > ul > li').first())
  testListView.selectAnother($('#testElement > ul > li').last())
  equal testListView.selected.length, 2, "Two elements should have been selected"
  testListView.deselect($('#testElement > ul > li').first())
  equal testListView.selected.length, 1, "Only one element should have been selected after deselect"

asyncTest "should trigger reset event on @selected collection for multi-select ListView", 3, ->
  window.testListView = new Cartilage.Views.ListView(collection: testCollection, el: ($ '#testElement'), allowsMultipleSelection: yes)
  testListView.prepare()
  testListView.selected.on "reset", ->
    ok true, "Reset event should have been triggered."
    start()
  testListView.select($('#testElement > ul > li').first())
  testListView.selectAnother($('#testElement > ul > li').last())
  equal testListView.selected.length, 2, "Two elements should have been selected"
  testListView.clearSelection()
  equal testListView.selected.length, 0, "No elements should have been selected"

