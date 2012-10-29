# Hack in support for constructor.name for IE >= 9
# http://matt.scharley.me/2012/03/09/monkey-patch-name-ie.html
# http://stackoverflow.com/questions/332422/how-do-i-get-the-name-of-an-objects-type-in-javascript
if Function.prototype.name == undefined and Object.defineProperty != undefined
  Object.defineProperty( Function.prototype,'name',
    get: () ->
      funcNameRegex = /function\s([^(]{1,})\(/
      results = (funcNameRegex).exec(@toString())
      return if results and results.length > 1 then results[1].trim() else ""
    set: (value) -> {} )