### define
react : React
react-bootstrap : ReactBootstrap
with_react : withReact
object_viewer : ObjectViewer
./navigation_view : NavigationView
./callhistory_view : CallHistoryView
./code_view : CodeView
###

R = withReact.R

App = React.createClass

  getInitialState : ->

    searchQuery : ""
    narrowCallHistory : false
    currentFunction : null

  handleSearch : (searchQuery) ->

    @setState {searchQuery}


  toggleNarrowCallHistory : ->

    @setState(React.addons.update(@state,
      narrowCallHistory :
        $apply : (b) -> !b
    ))


  render : ->

    setCurrentFunction = (jsFunction) =>

      @setState(React.addons.update(@state, {
        currentFunction :
          $set : jsFunction
      }))


    R.div {},
      NavigationView { onSearch : @handleSearch, searchQuery : @state.searchQuery }
      R.div {className : "container"},
        CallHistoryView {
          searchQuery : @state.searchQuery
          callHistoryData : @props.callHistoryData
          narrowCallHistory : @state.narrowCallHistory,
          setCurrentFunction
        }
      new CodeView({data : @state.currentFunction})


