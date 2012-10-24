
@READONLY  = 1
@READWRITE = 2

Function::property = (name, options = {}) ->
  options.access ?= (READONLY | READWRITE)
  options.default ?= null
  options.variable ?= "_#{name}"
  options.get ?= null
  options.set ?= null

  readable  = options.access & READONLY
  writeable = options.access & READWRITE

  getter = options.get or ->
    @[options.variable]

  setter = options.set or (value) ->
    @[options.variable] = value

  config =
    writeable: writeable
    get: getter if readable
    set: if writeable then setter else ()->
    configurable: no
    enumerable: yes

  @prototype[options.variable] = options.default
  Object.defineProperty @prototype, name, config
