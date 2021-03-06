module "Cartilage.Views.BasicListView"
  setup: ->
    @testCollection = new Backbone.Collection([ {id: 1, name: "one"}, 
                                              {id: 2, name: "two"}, 
                                              {id: 3, name: "three"} ],
                                              model: Backbone.Model)

    @testListView = new Cartilage.Views.ListView
      collection: @testCollection

test "should render collection correctly", 3, ->
  @testListView.prepare()
  $('#testElement').html @testListView.render().el 
  ok $('.list-view').length, "ListView container was created."
  equal $('.list-view-items-container > li').length, 3, "testListView should have 3 items."
  equal @testListView.selected.length, 0, "testListView should have 0 selected items."

test "should add an item to the list view", 3, ->
  @testListView.prepare()
  $('#testElement').html @testListView.render().el
  ok $('.list-view').length, "ListView container was created."
  equal $('.list-view-items-container > li').length, 3, "testListView should have 3 items."
  @testCollection.add({id: 4, name: "four"})
  equal $('.list-view-items-container > li').length, 4, "testListView should now have 4 items."

test "should remove an item from the list view", 3, ->
  @testListView.prepare()
  $('#testElement').html @testListView.render().el
  ok $('.list-view').length, "ListView container was created."
  equal $('.list-view-items-container > li').length, 3, "testListView should have 3 items."
  @testCollection.remove(@testCollection.get(3))
  equal $('.list-view-items-container > li').length, 2, "testListView should now have 2 items."

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

test "should keep selected items collection in the same order as collection passed to the view", 5, ->
  @testListView.prepare()
  $('#testElement').html @testListView.render().el
  
  @testListView.select($('.list-view > ul.list-view-items-container > li').first())
  @testListView.selectAnother($('.list-view > ul.list-view-items-container > li').last())

  equal @testListView.collection.at(0), @testListView.selected.at(0)
  equal @testListView.collection.at(2), @testListView.selected.at(1)

  @testListView.selectAnother($('.list-view > ul.list-view-items-container > li')[1])

  equal @testListView.collection.at(0), @testListView.selected.at(0)
  equal @testListView.collection.at(1), @testListView.selected.at(1)
  equal @testListView.collection.at(2), @testListView.selected.at(2)

module "Cartilage.Views.ListView.Ordered"
  setup: ->
    @testListView = null
    @testCollection = new Backbone.Collection(  [], 
                                                model: Backbone.Model,
                                                comparator: (item) -> item.get("name")
                                            )
    @testListView = new Cartilage.Views.ListView
      collection: @testCollection
      ordered: yes

test "should render items inserted into the collection in the proper order on the screen", 9, ->
  @testListView.prepare()
  $('#testElement').html @testListView.render().el
  equal $('#testElement li').length, 0, "No elements should have been rendered"
  @testCollection.add({id: "charlie", name: "charlie"})
  equal $('#testElement li').length, 1, "One element should have been rendered"
  @testCollection.add({id: "alpha", name: "alpha"})
  equal $('#testElement li').length, 2, "Two elements should have been rendered"
  equal $('#testElement li').first().data('model'), @testCollection.get("alpha"), "alpha should have been rendered first"
  equal $('#testElement li').last().data('model'), @testCollection.get("charlie"), "charlie should have been rendered last"
  @testCollection.add({id: "bravo", name: "bravo"})
  equal $('#testElement li').length, 3, "Three elements should have been rendered"
  equal $('#testElement li').first().data('model'), @testCollection.get("alpha"), "alpha should have been rendered first"
  equal $('#testElement li').eq(1).data('model'), @testCollection.get("bravo"), "bravo should have been rendered second"
  equal $('#testElement li').last().data('model'), @testCollection.get("charlie"), "charlie should have been rendered last"

test "should render removed items back into the proper position", 4, ->
  @testCollection.add([{id: "alpha", name: "alpha"}, {id: "bravo", name: "bravo"}, {id: "charlie", name: "charlie"}])
  @testListView.prepare()
  $('#testElement').html @testListView.render().el
  equal $('#testElement li').length, 3, "Three elements should have been rendered"
  @bravo = @testCollection.get("bravo")
  @testCollection.remove(@bravo)
  equal $('#testElement li').length, 2, "Two elements should have been rendered"
  @testCollection.add(@bravo)
  equal $('#testElement li').length, 3, "Three elements should have been rendered"
  equal $('#testElement li').eq(1).data('model'), @testCollection.get("bravo"), "bravo should have been reinserted second"


# This is how I'd like to test to make sure clicks get passed through to links contained
# in the ListViewItem, but there's no way to simulate a click at coordinates in pure JS.
#
# module "Cartilage.Views.ListView.SelectionDisabled"
#   setup: ->
#     @testListView = null

#     class window.TestModel extends Backbone.Model
#     @testCollection = new Backbone.Collection([ {id: 1, name: "one"}, 
#                                               {id: 2, name: "two"}, 
#                                               {id: 3, name: "three"} ],
#                                               model: TestModel)

#     class window.TestListViewItem extends Cartilage.Views.ListViewItem
#     window.JST = { "test_list_view_item": _.template('<a href="<%= testModel.get(\'name\') %>" id="link-<%= testModel.get(\'id\') %>">Link</a>')}

#     @testListView = new Cartilage.Views.ListView
#       collection: @testCollection
#       allowsSelection: no
#       allowsDeselction: no
#       itemView: TestListViewItem

# asyncTest "should pass a click in the listview through to the underlying element", 1, ->
#   @testListView.prepare() 
#   $('#testElement').html @testListView.render().el
#   $('#testElement a#link-1').click (e) -> 
#     ok true, "Click was received"
#     start()
#     e.preventDefault();
#   offset = $('#testElement a#link-1').offset();
#   $("#testElement a#link-1").simulate("click", {screenX: offset.left + 5, screenY: offset.top + 5}) 
