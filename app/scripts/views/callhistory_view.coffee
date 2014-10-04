### define
react : React
react-bootstrap : ReactBootstrap
with_react : withReact
object_viewer : ObjectViewer
./invocation_container_view : InvocationContainerView

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

    R.div {className},
      InvocationContainerView {
        invocation : @props.callHistoryData
        searchQuery : @props.searchQuery
        collapsed : false
        hidden : false,
        setCurrentFunction : @props.setCurrentFunction
      }

