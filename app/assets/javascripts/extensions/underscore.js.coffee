
#
# Iterates over an array of numbers and returns the sum. Example:
#
#    _.sum([1, 2, 3]) => 6
#
_.sum = (obj) ->
  return 0 if !_.isArray(obj) or obj.length is 0
  _.reduce obj, (sum, n) -> sum += n

#
# Converts underscored or camel-cased strings to dashes. Example:
#
#    _.dasherize("FooBarView") => "foo-bar-view"
#    _.dasherize("foo_bar_view") => "foo-bar-view"
#
_.dasherize = (string) ->
  return unless string

  # Remove Camelization
  string = string.replace /([A-Z])/g, (match) -> "-#{match.toLowerCase()}"

  # Convert Underscores to Dashes
  string = string.replace /_/g, "-"

  # Remove Leading Dash
  string.replace /^-/, ""

#
# Converts titlecased, underscored or dashed strings to camel-case. Example:
#
#    _.camelize("FooBarView") => "fooBarView"
#    _.camelize("foo-bar-view") => "fooBarView"
#    _.camelize("foo_bar_view") => "fooBarView"
#
_.camelize = (string) ->
  return unless string

  # Remove Camelization
  string = string.replace /((_|-)([a-z]))/g, (match) -> match[1].toUpperCase()

  # Convert First Letter to Lowercase
  string = string.replace /^([A-Z])/g, (match) -> match.toLowerCase()

#
# Converts dashed or camel-cased strings to dashes. Example:
#
#    _.underscore("FooBarView") => "foo_bar_view"
#    _.underscore("foo-bar-view") => "foo_bar_view"
#
_.underscore = (string) ->
  return unless string

  # Remove Camelization
  string = string.replace /([A-Z])/g, (match) -> "_#{match.toLowerCase()}"

  # Convert Dashes to Underscores
  string = string.replace /-/g, "_"

  # Remove Leading Underscore
  string.replace /^_/, ""

#
# Removes the specified value from the given array.
#
#    _.remove([ "A", "B", "C" ], "B") => [ "A", "C" ]
#
_.remove = (array, value) ->
  index = array.indexOf(value)
  array.splice(index, 1) unless index is -1
