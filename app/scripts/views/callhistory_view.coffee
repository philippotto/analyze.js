### define
react : React
react-bootstrap : ReactBootstrap
with_react : withReact
object_viewer : ObjectViewer
./invocation_container_view : InvocationContainerView

###

R = withReact.R

CallHistoryView = React.createClass

  getInitialState : ->

    rootInvocation :
      children : []
      isRoot : true


  render : ->

    additionalClass = if @props.narrowCallHistory then "callhistory-narrow" else ""

    R.div {className : "call-history " + additionalClass},
      InvocationContainerView {
        invocation : @props.callHistoryData
        searchQuery : @props.searchQuery
        collapsed : false
        hidden : false
      }

