### define
./JSFunction : JSFunction
###

# TODO: change to non-global

window.FunctionStore =

  functions : {}

  splitID : (id) ->

    [fileURL, fnName, range] = id.split("-")
    {fileURL, fnName, range}


  getOrCreateFunctionByID : (id, fnProperties) ->

    if fn = @functions[id]
      return fn

    else

      { fileURL, source, name, range, params } = fnProperties
      return @functions[id] = new JSFunction(id, fileURL, source, name, params)
