
@READONLY  = 1
@READWRITE = 2

Function::property = (name, options = {}) ->
  
  options.access ?= (READONLY | READWRITE)
  options.default ?= null
  options.internal_accessor ?= "_#{name}"
  options.variable ?= "__#{name}"
  options.get ?= null
  options.set ?= null

  readable  = options.access & READONLY
  writeable = options.access & READWRITE

  getter = options.get or ->
    if !_.has(@, options.variable) and _.isObject(@[options.variable]) and !_.isFunction(@[options.variable])
      @[options.variable] = _.clone(@[options.variable])
    @[options.variable]

  setter = options.set or (value) ->
    @[options.variable] = value

  public_config =
    writeable: writeable
    get: getter if readable
    set: if writeable then setter else ()->
    configurable: no
    enumerable: yes

  internal_config = 
    writeable: true
    get: getter
    set: setter
    configurable: no
    enumerable: yes

  # Create the public accessor
  Object.defineProperty @prototype, name, public_config

  # Create the internal accessor
  Object.defineProperty @prototype, options.internal_accessor, internal_config

  @prototype[options.variable] = options.default
