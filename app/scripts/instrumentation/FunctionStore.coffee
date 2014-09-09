### define
./JSFunction : JSFunction
###


window.FunctionStore =

  functions : {}


  # createID : (fileName, node) ->

  #   if not node.id?
  #     node.id =
  #       name : "anonymousFn"
  #       range : node.range

  #   fnName = node.id.name
  #   # TODO: check if node.id.range === node.range
  #   range = node.id.range


  #   [fileName, fnName, range].join("-")


  splitID : (id) ->

    [fileName, fnName, range] = id.split("-")
    {fileName, fnName, range}


  getOrCreateFunctionByID : (id) ->

    if fn = @functions[id]
      return fn
    else

      { fileName, source, name, range, params } = id
      return @functions[id] = new JSFunction(id, fileName, source, name, params)
