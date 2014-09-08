### define
./JSFunction : JSFunction
###


window.FunctionStore =

  functions : {}

  createFunction : (fileName, node, params) ->

    id = @createID(fileName, node)

    unless @functions[id]
      @functions[id] = new JSFunction(id, fileName, node, params)

    return @functions[id]


  createID : (fileName, node) ->

    if not node.id?
      node.id =
        name : "anonymousFn"
        range : node.range

    fnName = node.id.name
    # TODO: check if node.id.range === node.range
    range = node.id.range


    [fileName, fnName, range].join("-")


  getFunctionByID : (id) ->

    if fn = @functions[id]
      return fn

    throw Error("Function could not be found")
