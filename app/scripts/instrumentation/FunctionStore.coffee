### define
./JSFunction : JSFunction
###

# TODO: change to non-global

window.FunctionStore =

  functions : {}

  splitID : (id) ->

    [fileName, fnName, range] = id.split("-")
    {fileName, fnName, range}


  getOrCreateFunctionByID : (id, fnProperties) ->

    if fn = @functions[id]
      return fn

    else

      { fileName, source, name, range, params } = fnProperties
      return @functions[id] = new JSFunction(id, fileName, source, name, params)
