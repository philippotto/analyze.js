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

  addChild : (child) ->
    @children.push child

  stopInvocation : (@returnValue, @thrownException) ->
    @endTime = performance.now()

  changesDOM : (bool) ->
    if arguments.length == 0
      return @changedDOM
    else
      @changedDOM = bool

  getTotalTime : ->
    @endTime - @startTime

  getPureTime : ->

    @getTotalTime() - _.invoke(@children, "getTotalTime").reduce(
      (sum, num) -> sum + num,
      0
    )

  getArguments : ->
    @params

  getContext : ->
    @context

  getViewableArguments : ->

    # Returns an array where each element is an object in the form of:
    # parameter : argument
    # The parameter is a string which is derived by the function parameter list.
    # The argument is the passed variable.
    # Mind that you can provide fewer/more arguments than parameters to a function.

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
      el

      viewableArguments.push el

    viewableArguments

  getFormattedArguments : ->

    # TODO: use an object viewer and better abbreviations

    paramsAsStringArray = @params.map Formatter.formatValue

    "[#{paramsAsStringArray}]"

  getReturnValue : ->

    @returnValue

  getFormattedReturnValue : ->

    Formatter.formatValue @returnValue

  matches : (query) ->

    return @jsFunction.matches(query)

  hasChildren : ->

    @children.length
