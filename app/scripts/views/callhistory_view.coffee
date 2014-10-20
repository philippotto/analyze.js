### define
react : React
react-bootstrap : ReactBootstrap
with_react : withReact
./object_viewer : ObjectViewer
./invocation_container_view : InvocationContainerView
./invocation_view : InvocationView

###

R = withReact.R
classSet = React.addons.classSet

CallHistoryView = React.createClass

  getInitialState : ->

    rootInvocation :
      children : []
      isRoot : true


  render : ->

    className = classSet(
      "call-history" : true
      "callhistory-narrow" : @props.narrowCallHistory
    )

    collectInvocations = (root, n, nodes = []) ->

      if nodes.length == n
        return nodes

      nodes.push(root)
      root.children.forEach((childNode) ->
        collectInvocations(childNode, n, nodes)
      )

      return nodes


    root = @props.callHistoryData
    invocations = collectInvocations(root, 100)
    console.log("invocations",  invocations)
    console.log("length == 100 ?",  invocations.length)

    invocationViews = invocations.map((invocation) =>
      InvocationView(
        invocation : invocation
        searchQuery : @props.searchQuery
        collapsed : false #@state.collapsed
        hidden : false #@props.hidden
        toggleCollapsing : -> # @collapse
        setCurrentFunction : @props.setCurrentFunction
        key : "invocation-" + invocation.id
      )
    )


    R.div {className},
      invocationViews

