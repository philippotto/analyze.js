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

  mixins: [PureRenderMixin]

  getInitialState : ->

    collapsed : false


  render : ->

    invocationNodes = @props.invocation.children.map (invocation) =>
      InvocationContainerView {
        invocation
        searchQuery : @props.searchQuery
        hidden : @props.hidden or @state.collapsed
        key : "invocation-container-" + invocation.id
      }

    R.div {className : "invocation-container"},
      InvocationView(
        invocation : @props.invocation
        searchQuery : @props.searchQuery
        collapsed : @state.collapsed
        hidden : @props.hidden
        toggleCollapsing : @collapse
      )
      invocationNodes


  getInitialState : ->

    collapsed : false


  collapse : (evt) ->

    evt.stopPropagation()
    @setState({collapsed : !@state.collapsed})
