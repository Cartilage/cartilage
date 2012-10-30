# Add a no-op version of the console object so calls to
# console won't raise errors in IE < 10.
if typeof(console) == "undefined"
  window.console = 
    log: () ->
    debug: () ->
    info: () ->
    warn: () ->
    error: () ->