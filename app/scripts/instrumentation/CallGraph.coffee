### define
./InvocationNode : InvocationNode
###


class CallGraph

  constructor : ->
    @invocationIDCounter = 0
    @root = new InvocationNode()
    @root.isRoot = true
    @activeNode = @root

  resetToRoot : ->

    @activeNode = @root

  pushInvocation : (invocationNode) ->

    # TODO: find a better place for the id
    invocationNode.id = @invocationIDCounter++
    @activeNode.addChild(invocationNode)
    invocationNode.parentInvocation = @activeNode
    @activeNode = invocationNode

  popInvocation : (returnValue, thrownException) ->

    @activeNode.stopInvocation(returnValue, thrownException)
    @activeNode = @activeNode.parentInvocation

  registerDOMModification : =>

    @activeNode?.changesDOM(true)

