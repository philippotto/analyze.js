### define
react : React
react-bootstrap : ReactBootstrap
with_react : withReact
./object_viewer : ObjectViewer
./navigation_view : NavigationView
./callhistory_view : CallHistoryView
./code_view : CodeView
###

R = withReact.R
classSet = React.addons.classSet

AppView = React.createClass

  getInitialState : ->

    searchQuery : ""
    narrowCallHistory : false
    currentFunction : null


  handleSearch : (searchQuery) ->

    console.time("handleSearch")
    @setState {searchQuery}


  toggleNarrowCallHistory : ->

    @setState(React.addons.update(@state,
      narrowCallHistory :
        $apply : (b) -> !b
    ))


  componentDidUpdate : ->

    console.timeEnd("handleSearch")


  render : ->

    setCurrentFunction = (jsFunction) =>

      @setState(React.addons.update(@state, {
        currentFunction :
          $set : jsFunction
      }))


    callHistoryView = CallHistoryView {
      searchQuery : @state.searchQuery
      callHistoryData : @props.callHistoryData
      narrowCallHistory : @state.narrowCallHistory,
      setCurrentFunction
    }
    codeView = new CodeView(data : @state.currentFunction)

    outerFlexClass = "flexbox-item fill-area flexbox-item-grow"
    innerFlexClass = "fill-area-content flexbox-item-grow"

    codeClasses = classSet(
      "outerFlexClass" : true
      "lower-pane" : true
      "flex-fixed" : true
      "flex-zero" : !@state.currentFunction?
    )

    R.div {className : "flexbox-parent"},
      NavigationView
        className : "flexbox-item header"
        onSearch : @handleSearch
        searchQuery : @state.searchQuery
      R.div {className : outerFlexClass},
        R.div {className : innerFlexClass},
          callHistoryView
      R.div {className : codeClasses},
        R.div {className : innerFlexClass},
          codeView


