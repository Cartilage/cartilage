
module "Cartilage.View"

  setup: ->
    window.TestView = null

test "superview property should be read-only", ->
  testView = new Cartilage.View
  testView.superview = "foobar"
  ok _.isNull(testView.superview), "superview should be null"

test "subviews property should be read-only", ->
  testView = new Cartilage.View
  testView.subviews = "foobar"
  deepEqual testView.subviews, [], "subviews should be an empty array"

test "observers property should be read-only", ->
  testView = new Cartilage.View
  testView.observers = "foobar"
  deepEqual testView.observers, [], "observers should be an empty array"

test "addSubview method should add the view to subviews array", ->
  class TestView extends Cartilage.View
  class TestSubview extends Cartilage.View
  testView = new TestView
  testSubview = new TestSubview
  testView.addSubview(testSubview)
  deepEqual testView.subviews, [ testSubview ], "testSubview should be in the subviews array"

test "addSubview should add subview's element to its element", ->
  class TestView extends Cartilage.View
  class TestSubview extends Cartilage.View
  testView = new TestView
  testSubview = new TestSubview
  testView.addSubview(testSubview)
  equal testSubview.outerHTML, testView.innerHTML, "innerHTML of testView's element should match testSubview's outerHTML"

test "addSubview should set the superview of the added subview to itself", ->
  class TestView extends Cartilage.View
  class TestSubview extends Cartilage.View
  testView = new TestView
  testSubview = new TestSubview
  testView.addSubview(testSubview)
  equal testSubview.superview, testView, "testSubview's superview should be equal to testView"

test "removeFromSuperview method remove the view from its parent view's subviews array", ->
  class TestView extends Cartilage.View
  class TestSubview extends Cartilage.View
  testView = new TestView
  testSubview = new TestSubview
  testView.addSubview(testSubview)
  deepEqual testView.subviews, [ testSubview ], "testSubview should be in the subviews array"
  testSubview.removeFromSuperview()
  deepEqual testView.subviews, [], "testView.subviews should be an empty array"

test "removeFromSuperview should clear the superview property", ->
  class TestView extends Cartilage.View
  class TestSubview extends Cartilage.View
  testView = new TestView
  testSubview = new TestSubview
  testView.addSubview(testSubview)
  equal testSubview.superview, testView, "testSubview's superview should be equal to testView"
  testSubview.removeFromSuperview()
  equal testSubview.superview, null, "testSubview's superview should be null"

test "should determine template name automatically", ->
  window.JST = { "test_view": -> "TestView Template" }
  class TestView extends Cartilage.View
  testView = new TestView
  equal testView.template(), "TestView Template", "template() should return 'TestView Template'"

test "should determine CSS class names from the inheritance chain", ->
  class TestViewOne extends Cartilage.View
  class TestViewTwo extends TestViewOne
  class TestViewThree extends TestViewTwo
  testView = new TestViewThree
  className = testView.determineClassName()
  equal className, "view test-view-one test-view-two test-view-three", "Class names array should include names for each parent in the inheritance chain"

test "should append custom CSS class names to the view's class names", ->
  class TestView extends Cartilage.View
    className: "extra-class-one extra-class-two"
  testView = new TestView
  className = testView.determineClassName()
  equal className, "view test-view extra-class-one extra-class-two", "Class names should include both automatically determined names and custom names"
