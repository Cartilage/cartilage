
module "Extensions.Properties"

  setup: ->

test "should initialize property", ->

  class TestView extends Cartilage.View
    @property "testProperty"
  testView = new TestView

  ok not _.isUndefined(testView._testProperty), "_testProperty should not be undefined"
  ok _.isNull(testView._testProperty), "_testProperty should be null"

test "should initialize property with default value", ->

  class TestView extends Cartilage.View
    @property "testProperty", default: "foo"
  testView = new TestView

  equal testView.testProperty, "foo", "testProperty should equal 'foo'"

test "should disallow changes to read-only properties", ->

  class TestView extends Cartilage.View
    @property "testProperty", access: READONLY
  testView = new TestView

  testView.testProperty = "foobar"
  ok _.isNull(testView.testProperty), "testProperty should be null"

test "should initialize read-only property with default value", ->

  class TestView extends Cartilage.View
    @property "testProperty", access: READONLY, default: "foobar"
  testView = new TestView

  equal testView.testProperty, "foobar", "testProperty should equal 'foobar'"

test "should initialize property with custom getter", ->

  class TestView extends Cartilage.View
    @property "testProperty",
      get: -> "customGetter"
  testView = new TestView

  equal testView.testProperty, "customGetter", "testProperty should equal 'customGetter'"

test "should initialize property with custom setter", ->

  class TestView extends Cartilage.View
    @property "testProperty",
      set: (value) -> @_testProperty = "customSetter"
  testView = new TestView
  testView.testProperty = "foo"

  equal testView.testProperty, "customSetter", "testProperty should equal 'customSetter'"

test "should initialize property via super()", ->

  class TestView extends Cartilage.View
    @property "testProperty"

    initialize: (options = {}) ->
      options.testProperty = "bar"
      super(options)
      
  testView = new TestView
  equal testView.testProperty, "bar"
