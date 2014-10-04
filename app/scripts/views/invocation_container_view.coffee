### define
react : React
react-bootstrap : ReactBootstrap
with_react : withReact
object_viewer : ObjectViewer
./invocation_view : InvocationView
###

R = withReact.R
PureRenderMixin = React.addons.PureRenderMixin

InvocationContainerView = React.createClass

  # doesn't work for live rendering since the CallGraph is not pure
  # mixins: [PureRenderMixin]

  getInitialState : ->

    collapsed : false


  render : ->

    invocationNodes = @props.invocation.children.map (invocation) =>
      InvocationContainerView {
        invocation
        searchQuery : @props.searchQuery
        hidden : @props.hidden or @state.collapsed
        key : "invocation-container-" + invocation.id
        setCurrentFunction : @props.setCurrentFunction
      }

    R.div {className : "invocation-container"},
      InvocationView(
        invocation : @props.invocation
        searchQuery : @props.searchQuery
        collapsed : @state.collapsed
        hidden : @props.hidden
        toggleCollapsing : @collapse
        setCurrentFunction : @props.setCurrentFunction
      )
      invocationNodes


  getInitialState : ->

    collapsed : false


  collapse : (evt) ->

    evt.stopPropagation()
    @setState({collapsed : !@state.collapsed})
