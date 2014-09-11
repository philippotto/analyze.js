### define
./InvocationNode : InvocationNode
./FunctionStore : FunctionStore
###

class Tracer

  constructor : (@callGraph, listenToDOMModifications) ->

    if listenToDOMModifications
      document.addEventListener("DOMSubtreeModified", @callGraph.registerDOMModification, false)


  traceEnter : (id, fnProperties, params, context) ->

    jsFunction = FunctionStore.getOrCreateFunctionByID(id, fnProperties)
    invocationNode = new InvocationNode(jsFunction, params, context)

    @callGraph.pushInvocation invocationNode


  traceExit : (id, returnValue, thrownException) ->

    if id != @callGraph.activeNode.jsFunction.id
      # TODO: integrate assertion library
      console.error("traceExit was called for a different function than traceEnter")

    @callGraph.popInvocation(returnValue, thrownException)

    app.execute("renderCallGraph")


  getRoot : ->

    @callGraph.root
