
module "Cartilage.Views.ListViewItem"

  setup: ->
    @testCollection = new Backbone.Collection([ {id: 1, name: "one"}, 
                                              {id: 2, name: "two"}, 
                                              {id: 3, name: "three"} ],
                                              model: Backbone.Model)

    @testListView = new Cartilage.Views.ListView
      collection: @testCollection
      allowsDragToReorder: yes

test "should contain data-model-id on list items", 3, ->
  @testListView.prepare()
  $('#testElement').html @testListView.render().el 
  _.each([1,2,3], (itemId) => ok $("*[data-model-id='" + itemId + "']").length > 0)
