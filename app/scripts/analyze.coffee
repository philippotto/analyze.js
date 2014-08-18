### define
falafel : falafel
react : React
react-bootstrap : ReactBootstrap
###

->

  window.FunctionStore =

    functions : {}

    createFunction : (fileName, node) ->

      id = @createID(fileName, node)

      unless @functions[id]
        @functions[id] = new JSFunction(id, fileName, node)

      return @functions[id]


    createID : (fileName, node) ->

      fnName = node.id.name
      range = node.id.range

      [fileName, fnName, range].join("-")


    getFunctionByID : (id) ->

      if fn = @functions[id]
        return fn

      throw Error("Function could not be found")



  class JSFunction

    constructor : (@id, @fileName, @node) ->


    getSourceString : -> @node.source()

    getFileName : -> @fileName

    getName : -> @node.id.name

    matches : (query) ->

      _.any([@getName(), @getFileName()], (property) ->
        property.toLowerCase().indexOf(query.toLowerCase()) > -1
      )



  class InvocationNode

    constructor : (@jsFunction, @params, @context) ->
      @children = []
      @startTime = performance.now()

    addChild : (child) ->
      @children.push child

    stopInvocation : ->
      @endTime = performance.now()

    getTime : ->
      @endTime - @startTime

    getFormattedTime : ->
      @getTime().toFixed(2) + " ms"

    getFormattedArguments : ->
      "[#{[].map.call(@params, (el) -> el.toString())}]"

    matches : (query) ->

      return @jsFunction.matches(query)


  class CallGraph

    constructor : ->
      @root = new InvocationNode()
      @root.isRoot = true
      @activeNode = @root

    pushInvocation : (invocationNode) ->

      @activeNode.addChild(invocationNode)
      invocationNode.parentInvocation = @activeNode
      @activeNode = invocationNode

    popInvocation : ->

      @activeNode.stopInvocation()
      @activeNode = @activeNode.parentInvocation



  class Tracer
    traceEnter : (id, params, context) ->

      jsFunction = FunctionStore.getFunctionByID(id)
      invocationNode = new InvocationNode(jsFunction, params, context)

      callGraph.pushInvocation invocationNode

      console.log "traceEnter was triggered", arguments

    traceExit : (id) ->
      console.log "traceExit was triggered", arguments
      callGraph.popInvocation()


  window.tracer = new Tracer()
  window.callGraph = new CallGraph()

  generateCallHistoryData = ->

    src =
      string : """
        function a(arg1, callee) {
          if (callee == null)
            b(arg1, "a is calling");
        }

        function b(arg1) {
          c(arg1, "b is calling");
        }

        function c(arg1) {
          a(arg1, "c is calling");
        }
        """
      fileName : "testFile.js"

    window.output = falafel(src.string, (node) ->
      console.log "node", node

      parent = node.parent

      # first two parts of condition could be enough?
      if parent and parent.type is "FunctionDeclaration" and node.type is "BlockStatement"
        jsFunction = FunctionStore.createFunction(src.fileName, parent)
        fnID = jsFunction.id

        node.update "{\ntracer.traceEnter('#{fnID}', arguments, this);\n" + node.source() + ";\ntracer.traceExit('#{fnID}');\n}"

    )

    eval(output.toString())
    a("anArg")
    a("anArg", "anArg")

    callGraph.root


  callHistoryData = generateCallHistoryData()


  # ################################################################################################
  # ################################################## React #######################################
  # ################################################################################################

  # CallHistory
  #   InvocationContainer
  #     Invocation


  R = _.merge(_.merge({}, ReactBootstrap), React.DOM)

  App = React.createClass

    getInitialState : ->

      searchQuery : ""
      callHistoryData : callHistoryData


    handleSearch : (searchQuery) ->

      @setState {searchQuery, callHistoryData}


    render : ->

      R.div {},
        Navigation { onSearch : @handleSearch, searchQuery : @state.searchQuery }
        R.div {className : "container"},
          CallHistory { searchQuery : @state.searchQuery, callHistoryData : @state.callHistoryData }



  Navigation = React.createClass

    handleSearch : ->

      searchQuery = @refs.searchInput.getValue()
      @props.onSearch(searchQuery)

    render : ->

      brand = R.a href:"#", className:"navbar-brand",
        "analyze.js"

      R.Navbar {inverse: true, brand},
        R.Nav {},
          R.form className : "navbar-form navbar-left", role : "search",
            R.div className : "form-group",
              R.Input {type: "text", className : "form-control", placeholder: "Search", onChange: @handleSearch, value: @props.searchQuery, ref: "searchInput"}
          R.DropdownButton key:3, title:"Dropdown",
            R.MenuItem key:"1",
              "Action"
            R.MenuItem divider : true
            R.MenuItem key:"4",
              "Separated link"



  CallHistory = React.createClass

    getInitialState : ->
      rootInvocation : {
        children : []
        isRoot : true,
      }


    render : ->
      R.div {className : "call-history"},
        InvocationContainer {invocation : @props.callHistoryData, searchQuery : @props.searchQuery}



  InvocationContainer = React.createClass
    render : ->

      invocationNodes = @props.invocation.children.map (invocation) =>
        InvocationContainer { invocation, searchQuery : @props.searchQuery }

      R.div {className : "invocation-container"},
        Invocation { invocation : @props.invocation, searchQuery : @props.searchQuery }
        invocationNodes



  Invocation = React.createClass

    render : ->
      eval(Object.keys(R).map((k) -> unless k is "var" then "var #{k} = R['#{k}']").join("; "))

      invocation = @props.invocation
      jsFunction = invocation.jsFunction
      nullElement = div {}

      console.log("@props.searchQuery",  @props.searchQuery)

      if invocation.isRoot
        return nullElement

      name = jsFunction.getName()

      unless invocation.matches(@props.searchQuery)
        return nullElement

      time = (invocation.endTime - invocation.startTime)


      popoverOverlay = R.Popover {title: "Popover top"}, "Holy moly"

      R.Panel {className : "invocation", onClick : @logInvocation},
        div {className : "pull-right"},
          jsFunction.getFileName()
          div {},
            R.Label bsStyle: "primary", className: "pull-right",
              invocation.getFormattedTime()
        h4 {}, name
        div {},
          R.OverlayTrigger {trigger: "click", placement: "top", overlay : popoverOverlay},
            div {}, "Arguments: " + invocation.getFormattedArguments()


    logInvocation : ->

      console.log("invocation",  @props.invocation)


  DOMroot = document.getElementById('main')
  React.renderComponent(
    App {}
    DOMroot
  )
