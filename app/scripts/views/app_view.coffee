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

    searchQuery : 'c(name, "") and c(path, "")'
    searchFilter : -> true
    narrowCallHistory : false
    currentFunction : null


  updateState : (query) ->

    @setState(React.addons.update(@state, query))


  setSearch : (searchQuery, searchFilter) ->

    console.time("setSearchQuery")
    @updateState(
      searchQuery :
        $set : searchQuery
      searchFilter :
        $set : searchFilter

    )


  toggleNarrowCallHistory : ->

    @updateState(
      narrowCallHistory :
        $apply : (b) -> !b
    )


  componentDidUpdate : ->

    console.timeEnd("setSearchQuery")


  render : ->

    setCurrentFunction = (jsFunction) =>

      @updateState(
        currentFunction :
          $set : jsFunction
      )


    callHistoryView = CallHistoryView {
      searchFilter : @state.searchFilter
      callGraph : @props.callGraph
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
        setSearch : @setSearch
        searchQuery : @state.searchQuery
      R.div {className : outerFlexClass},
        callHistoryView
      R.div {className : codeClasses},
        R.div {className : innerFlexClass},
          codeView


