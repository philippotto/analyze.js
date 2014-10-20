### define
react : React
react-bootstrap : ReactBootstrap
with_react : withReact
./object_viewer : ObjectViewer
./invocation_view : InvocationView
###

R = withReact.R
classSet = React.addons.classSet

pageHeight = 1000
invocationHeight = 32
invocationsPerPage = pageHeight / invocationHeight


CallHistoryView = React.createClass

  componentWillMount: ->

    @visiblePages = [ 0 ]


  componentDidMount: ->

    @onScroll()


  onScroll: (e) ->

    container = @getDOMNode()
    bellowFold = Math.ceil(container.scrollTop / pageHeight) or 1
    aboveFold = Math.ceil((container.scrollTop + 100 + container.clientHeight) / pageHeight)

    visiblePages = _.uniq([ bellowFold, aboveFold ])
    if _.isEqual(visiblePages, @visiblePages)
      return

    @visiblePages = visiblePages
    @forceUpdate()


  render : ->

    callGraph = @props.callGraph

    lowest = _.max([ _.first(@visiblePages) - 1, 0 ])
    highest = callGraph.getSize() / invocationsPerPage - _.last(@visiblePages)

    spacer =
      top :
        R.div({
          style: {height: lowest * pageHeight + "px"}
          className: "spacer top-spacer"
        }, null)
      bottom :
        R.div({
          style: {height: highest * pageHeight + "px"}
          className: "spacer bottom-spacer"
        }, null)


    className = classSet(
      "call-history" : true
      "callhistory-narrow" : @props.narrowCallHistory
      "fill-area-content" : true,
      "flexbox-item-grow" : true
    )

    root = callGraph.root

    if not @counter
      @counter = 0

    @collectedInvocations = callGraph.collectInvocations(
      root
      callGraph.getSize()
      @props.searchQuery
    )

    boundForceUpdateFn = @forceUpdate.bind(@)

    elements = @visiblePages.map((i) =>
      return @collectedInvocations
        .slice(invocationsPerPage * (i - 1), invocationsPerPage * i)
        .map((invocation) =>
          InvocationView(
            invocation : invocation
            searchQuery : @props.searchQuery
            forceUpdate : boundForceUpdateFn
            setCurrentFunction : @props.setCurrentFunction
            key : "invocation-" + invocation.id
          )
        )
    )

    R.div {className, onScroll: @onScroll},
      spacer.top
      elements
      spacer.bottom

