
module "Cartilage.Views.ImageView"

test "isLoaded property should be read-only", ->
  testImageView = new Cartilage.Views.ImageView
  testImageView.isLoaded = true
  ok testImageView.isLoaded == false, "isLoaded should be false"

test "isError property should be read-only", ->
  testImageView = new Cartilage.Views.ImageView
  testImageView.isError = true
  ok testImageView.isError == false, "isError should be false"

asyncTest "should fire load event upon successful load", ->
  testImageView = new Cartilage.Views.ImageView
    imageAddress: "http://www.placehold.it/500x500"
  testImageView.on "load", ->
    ok true
    start()

asyncTest "should fire error event upon unsuccessful load attempt", ->
  testImageView = new Cartilage.Views.ImageView
    imageAddress: '404'

  testImageView.on "error", ->
    ok true
    start()
