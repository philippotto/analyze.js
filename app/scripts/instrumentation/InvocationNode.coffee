### define
../Formatter : Formatter
###

class InvocationNode

  constructor : (@jsFunction, params, @context) ->

    if params
      @params = [].slice.call(params)
    else
      @params = []
    @children = []
    @startTime = performance.now()
    @changedDOM = false
    @dirty = true
    @isRoot = false


  addChild : (child) ->

    @children.push child
    @setDirty(true)


  stopInvocation : (@returnValue, @thrownException) ->

    @endTime = performance.now()
    @setDirty(true)


  setDirty : (bool) -> @dirty = bool

  getDirty : -> @dirty

  changesDOM : (bool) ->

    if arguments.length == 0
      return @changedDOM
    else
      @changedDOM = bool
      @setDirty(true)


  getTotalTime : -> @endTime - @startTime

  getPureTime : ->

    @getTotalTime() - _.invoke(@children, "getTotalTime").reduce(
      (sum, num) -> sum + num,
      0
    )


  getArguments : -> @params

  getContext : -> @context

  getViewableArguments : ->

    # Returns an array where each element is an object in the form of:
    # parameter : argument
    # The parameter is a string which is derived by the function parameter list.
    # The argument is the passed variable.
    # Mind that you can provide fewer/more arguments than parameters to a
    # function.

    i = -1
    params = @jsFunction.getParameters()
    args = @getArguments()
    viewableArguments = []

    while ++i < params.length
      el = {}
      el[params[i]] = args[i]

      viewableArguments.push el

    i--

    while ++i < args.length
      el = {}
      el["not listed"] = args[i]

      viewableArguments.push el

    viewableArguments


  getReturnValue : ->

    @returnValue


  matches : (query) ->

    if @isRoot
      # is it conceptionally sensible that the root is asked whether it matches?
      return true

    return @jsFunction.matches(query)


  hasChildren : ->

    @children.length
