### define
react : React
react-bootstrap : ReactBootstrap
with_react : withReact
object_viewer : ObjectViewer
./navigation_view : NavigationView
./callhistory_view : CallHistoryView
###

R = withReact.R

App = React.createClass

  getInitialState : ->

    searchQuery : ""
    narrowCallHistory : false


  handleSearch : (searchQuery) ->

    @setState {searchQuery}


  toggleNarrowCallHistory : ->

    # TODO: immutable.js ?
    @state.narrowCallHistory = !@state.narrowCallHistory
    @setState @state

  render : ->

    R.div {},
      NavigationView { onSearch : @handleSearch, searchQuery : @state.searchQuery }
      R.div {className : "container"},
        CallHistoryView {
          searchQuery : @state.searchQuery
          callHistoryData : @props.callHistoryData
          narrowCallHistory : @state.narrowCallHistory
        }

