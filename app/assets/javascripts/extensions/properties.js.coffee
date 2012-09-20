
@READONLY  = 1
@READWRITE = 2

Function::property = (name, options = {}) ->
  options.access ?= (READONLY | READWRITE)
  options.default ?= null
  options.variable ?= "_#{name}"
  options.get ?= "_get_#{name}"
  options.set ?= "_set_#{name}"

  readable  = options.access & READONLY
  writeable = options.access & READWRITE

  getter = @[options.get] or ->
    @[options.variable]

  setter = @[options.set] or (value) ->
    @[options.variable] = value

  config =
    writeable: writeable
    get: getter if readable
    set: setter if writeable
    configurable: no
    enumerable: yes

  using_default_getter_or_setter = @[options.get]? or @[options.set]?
  @prototype[options.variable] = options.default # if using_default_getter_or_setter
  Object.defineProperty @prototype, name, config
