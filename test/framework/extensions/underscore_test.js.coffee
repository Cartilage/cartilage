
module "Extensions.Underscore"

# _.sum ----------------------------------------------------------------------

test "_.sum should sum arrays of numbers", ->
  testArray = [ 1, 2, 3 ]
  equal _.sum(testArray), 6, "Value expected to be 6 (1 + 2 + 3)"

test "_.sum should return NaN for non-numeric array entries", ->
  testArray = [ 1, 2, "Foo" ]
  ok _.isNaN(_.sum(testArray)), "Value expected to be NaN"

# _.dasherize ----------------------------------------------------------------

test "_.dasherize should convert title-cased string to dasherized string", ->
  testString = "FooBarView"
  equal _.dasherize(testString), "foo-bar-view", "Value for '#{testString}' expected to be 'foo-bar-view'"

test "_.dasherize should convert camel-cased string to dasherized string", ->
  testString = "fooBarView"
  equal _.dasherize(testString), "foo-bar-view", "Value for '#{testString}' expected to be 'foo-bar-view'"

test "_.dasherize should convert underscored string to dasherized string", ->
  testString = "foo_bar_view"
  equal _.dasherize(testString), "foo-bar-view", "Value for '#{testString}' expected to be 'foo-bar-view'"

test "_.dasherize should leave dashed strings alone", ->
  testString = "foo-bar-view"
  equal _.dasherize(testString), "foo-bar-view", "Value for '#{testString}' expected to be 'foo-bar-view'"

# _.camelize -----------------------------------------------------------------

test "_.camelize should convert title-cased string to camel-cased string", ->
  testString = "FooBarView"
  equal _.camelize(testString), "fooBarView", "Value for '#{testString}' expected to be 'fooBarView'"

test "_.camelize should convert dashed string to camel-cased string", ->
  testString = "foo-bar-view"
  equal _.camelize(testString), "fooBarView", "Value for '#{testString}' expected to be 'fooBarView'"

test "_.camelize should convert underscored string to camel-cased string", ->
  testString = "foo_bar_view"
  equal _.camelize(testString), "fooBarView", "Value for '#{testString}' expected to be 'fooBarView'"

test "_.camelize should leave camel-cased strings alone", ->
  testString = "fooBarView"
  equal _.camelize(testString), "fooBarView", "Value for '#{testString}' expected to be 'fooBarView'"

# _.underscore ---------------------------------------------------------------

test "_.underscore should convert title-cased string to underscored string", ->
  testString = "FooBarView"
  equal _.underscore(testString), "foo_bar_view", "Value for '#{testString}' expected to be 'foo_bar_view'"

test "_.underscore should convert camel-cased string to underscored string", ->
  testString = "fooBarView"
  equal _.underscore(testString), "foo_bar_view", "Value for '#{testString}' expected to be 'foo_bar_view'"

test "_.underscore should convert dashed string to underscored string", ->
  testString = "foo-bar-view"
  equal _.underscore(testString), "foo_bar_view", "Value for '#{testString}' expected to be 'foo_bar_view'"

test "_.underscore should leave underscored strings alone", ->
  testString = "foo_bar_view"
  equal _.underscore(testString), "foo_bar_view", "Value for '#{testString}' expected to be 'foo_bar_view'"

# _.remove -------------------------------------------------------------------

test "_.remove should remove value from array", ->
  testArray = [ "A", "B", "C" ]
  _.remove(testArray, "B")
  deepEqual testArray, [ "A", "C" ], "foo"
