module "Cartilage.Views.ImageView"
  setup: ->
    @imageView = new Cartilage.Views.ImageView

test "isLoaded property should be read-only", 1, ->
  @imageView.isLoaded = true
  ok @imageView.isLoaded == false, "isLoaded should be false"

test "isError property should be read-only", 1, ->
  @imageView.isError = true
  ok @imageView.isError == false, "isError should be false"
  
asyncTest "should fire load event upon successful load", 1, ->
  @imageView.on "load", ->
    ok true, 'load called'
    start()

  @imageView.imageAddress = "http://www.placehold.it/500x500"
  $('#testElement').html @imageView.render().el 

asyncTest "should fire error event upon unsuccessful load attempt", 1, ->
  @imageView.on "error", ->
    ok true, 'error called'
    start()

  @imageView.imageAddress = '404'
  $('#testElement').html @imageView.render().el 
