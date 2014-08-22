### define
falafel : falafel
react : React
react-bootstrap : ReactBootstrap
with_react : withReact
object_viewer : ObjectViewer
###

->

  window.FunctionStore =

    functions : {}

    createFunction : (fileName, node, params) ->

      id = @createID(fileName, node)

      unless @functions[id]
        @functions[id] = new JSFunction(id, fileName, node, params)

      return @functions[id]


    createID : (fileName, node) ->

      if not node.id?
        node.id =
          name : "anonymousFn"
          range : node.range

      fnName = node.id.name
      # TODO: check if node.id.range === node.range
      range = node.id.range


      [fileName, fnName, range].join("-")


    getFunctionByID : (id) ->

      if fn = @functions[id]
        return fn

      throw Error("Function could not be found")



  class JSFunction

    constructor : (@id, @fileName, @node, @params) ->


    getSourceString : -> @node.source()

    getFileName : -> @fileName

    getName : -> @node.id.name

    getParameters : -> @params

    matches : (query) ->

      _.any([@getName(), @getFileName()], (property) ->
        property.toLowerCase().indexOf(query.toLowerCase()) > -1
      )



  class InvocationNode

    constructor : (@jsFunction, params, @context) ->
      if params
        @params = [].slice.call(params)
      else
        @params = []
      @children = []
      @startTime = performance.now()
      @changedDOM = false

    addChild : (child) ->
      @children.push child

    stopInvocation : (@returnValue, @thrownException) ->
      @endTime = performance.now()

    changesDOM : (bool) ->
      if arguments.length == 0
        return @changedDOM
      else
        @changedDOM = bool

    getTotalTime : ->
      @endTime - @startTime

    getPureTime : ->

      @getTotalTime() - _.invoke(@children, "getTotalTime").reduce(
        (sum, num) -> sum + num,
        0
      )

    getArguments : ->
      @params

    getContext : ->
      @context

    getViewableArguments : ->

      # Returns an array where each element is an object in the form of:
      # parameter : argument
      # The parameter is a string which is derived by the function parameter list.
      # The argument is the passed variable.
      # Mind that you can provide fewer/more arguments than parameters to a function.

      i = -1
      params = @jsFunction.getParameters()
      args = @getArguments()
      viewableArguments = []

      while ++i < params.length
        el = {}
        el[params[i]] = args[i]

        viewableArguments.push el

      i--

      while ++i < args.length
        el = {}
        el["not listed"] = args[i]
        el

        viewableArguments.push el

      viewableArguments

    getFormattedArguments : ->

      # TODO: use an object viewer and better abbreviations

      paramsAsStringArray = @params.map ObjectViewer.Formatter.formatValue

      "[#{paramsAsStringArray}]"

    getReturnValue : ->

      @returnValue

    getFormattedReturnValue : ->

      ObjectViewer.Formatter.formatValue @returnValue

    matches : (query) ->

      return @jsFunction.matches(query)

    hasChildren : ->

      @children.length


  class CallGraph

    constructor : ->
      @invocationIDCounter = 0
      @root = new InvocationNode()
      @root.isRoot = true
      @activeNode = @root

    resetToRoot : ->

      @activeNode = @root

    pushInvocation : (invocationNode) ->

      # TODO: find a better place for the id
      invocationNode.id = @invocationIDCounter++
      @activeNode.addChild(invocationNode)
      invocationNode.parentInvocation = @activeNode
      @activeNode = invocationNode

    popInvocation : (returnValue, thrownException) ->

      @activeNode.stopInvocation(returnValue, thrownException)
      @activeNode = @activeNode.parentInvocation

    registerDOMModification : =>

      @activeNode?.changesDOM(true)


  class Tracer

    constructor : (@callGraph, listenToDOMModifications) ->

      if listenToDOMModifications
        document.addEventListener("DOMSubtreeModified", @callGraph.registerDOMModification, false);


    traceEnter : (id, params, context) ->

      jsFunction = FunctionStore.getFunctionByID(id)
      invocationNode = new InvocationNode(jsFunction, params, context)

      @callGraph.pushInvocation invocationNode


    traceExit : (id, returnValue, thrownException) ->
      if id != @callGraph.activeNode.jsFunction.id
        # TODO: integrate assertion library
        console.error("traceExit was called for a different function than traceEnter")

      @callGraph.popInvocation(returnValue, thrownException)


  window.callGraph = new CallGraph()
  window.tracer = new Tracer(window.callGraph, true)


  instrumentCode = (codeString, fileName) ->

    falafel(codeString, (node) ->

      parent = node.parent

      # first two parts of condition could be enough?
      if parent?.type in ["FunctionDeclaration", "FunctionExpression"] and node.type is "BlockStatement"
        paramsAsStringArray = _.invoke(node.parent.params, "source")
        jsFunction = FunctionStore.createFunction(fileName, parent, paramsAsStringArray)
        fnID = jsFunction.id

        node.update """{
                    tracer.traceEnter('#{fnID}', arguments, this);
                    var thrownException = null;
                    try {
                      var returnValue = (function(#{paramsAsStringArray.join(", ")}) {
                        #{node.source()};
                      }).apply(this, arguments);
                    } catch(ex) {
                      thrownException = ex;
                    }
                    tracer.traceExit('#{fnID}', returnValue, thrownException);
                    if(thrownException)
                      throw thrownException;
                    return returnValue;
                    }"""
    )


  generateCallHistoryData = (src) ->

    instrumentedCode = instrumentCode(src.string, src.fileName)
    instrumentedTestCode = instrumentCode(src.testString, "test.js")

    eval(instrumentedCode.toString())
    eval(instrumentedTestCode.toString())

    return callGraph.root


  # ################################################################################################
  # ################################################## React #######################################
  # ################################################################################################

  # CallHistory
  #   InvocationContainer
  #     Invocation


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
        Navigation { onSearch : @handleSearch, searchQuery : @state.searchQuery }
        R.div {className : "container"},
          CallHistory {
            searchQuery : @state.searchQuery
            callHistoryData : @props.callHistoryData
            narrowCallHistory : @state.narrowCallHistory
          }



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
              R.Input {
                type: "text"
                className : "form-control"
                placeholder: "Search"
                onChange: @handleSearch
                value: @props.searchQuery
                ref: "searchInput"
              }
          R.DropdownButton key:3, title:"Dropdown",
            R.MenuItem key: "1",
              "Action"
            R.MenuItem divider : true
            R.MenuItem key: "4",
              "Separated link"



  CallHistory = React.createClass

    getInitialState : ->

      rootInvocation :
        children : []
        isRoot : true


    render : ->

      additionalClass = if @props.narrowCallHistory then "callhistory-narrow" else ""

      R.div {className : "call-history " + additionalClass},
        InvocationContainer {
          invocation : @props.callHistoryData
          searchQuery : @props.searchQuery
          collapsed : false
          hidden : false
        }



  PureRenderMixin = React.addons.PureRenderMixin

  InvocationContainer = React.createClass

    mixins: [PureRenderMixin]

    getInitialState : ->

      collapsed : false


    render : ->

      invocationNodes = @props.invocation.children.map (invocation) =>
        InvocationContainer {
          invocation
          searchQuery : @props.searchQuery
          hidden : @props.hidden or @state.collapsed
          key : "invocation-container-" + invocation.id
        }

      R.div {className : "invocation-container"},
        Invocation(
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


  Invocation = React.createClass

    render : ->
      eval(withReact.import)

      invocation = @props.invocation
      jsFunction = invocation.jsFunction

      if invocation.isRoot
        return div {}

      popoverOverlay = R.Popover {title: "Arguments"},
        ObjectViewer { object : invocation.getViewableArguments() }


      div className : "invocation", style : @getStyle(), onDoubleClick : @props.toggleCollapsing,
        div className : "pull-right",
          div onClick : @logInvocation,
            jsFunction.getFileName()
            @getTimeMarker(invocation)
        div {},
          @getToggler()
          span className : "function-name",
            jsFunction.getName()
          span {},
            OverlayTrigger {trigger: "click", placement: "right", overlay : popoverOverlay},
              span {},
                "(#{invocation.getFormattedArguments()})"
          span {onClick : -> console.log(invocation.getReturnValue())},
              " → " + invocation.getFormattedReturnValue()
          em {onClick : -> console.log(invocation.getContext())},
              " context"
          span {},
            if invocation.changesDOM() then Label bsStyle: "warning", "Changes DOM"


    formatTime : (t) -> t.toFixed(2) + " ms"

    getTimeMarker: (invocation) ->
      eval(withReact.import)

      timeTooltip = Tooltip {},
        div {}, "Total time: " + @formatTime invocation.getTotalTime()
        div {}, "Pure time: " + @formatTime invocation.getPureTime()

      OverlayTrigger {trigger: "hover", placement: "right", overlay : timeTooltip},
        div className : "circle pull-right " + if invocation.getTotalTime() > 0 then "slow" else "fast"


    getToggler: ->

      if @props.invocation.hasChildren()
        R.div {
          className: "triangle " + if @props.collapsed then "closed" else "open"
          ref : "collapseToggler"
          onClick : @props.toggleCollapsing
        }


    getStyle: ->

      matches = @props.invocation.matches(@props.searchQuery)
      return display : if matches and not @props.hidden then "block" else "none"


    logInvocation : ->

      console.log("invocation",  @props.invocation)





  $.ajax("Immutable.js", {dataType: "text"}).then (immutableCode) ->

    getTestCase = ->
      testcase = "immutable"
      switch testcase
        when "immutable"
          string : immutableCode
          fileName : "immutable.js"
          testString : "map = Immutable.Map({a : 1, b : 2, c : 3}); map.set('d', 4)"

        when "simpleCallHierarchy"
          string : """
            function a(arg1, callee) {
              if (callee == null)
                return "a" + b(arg1, "a is calling");
              return "a";
            }

            function b(arg1) {
              var mytext=document.createTextNode("some text");
              console.log("going to change the dom");
              document.body.appendChild(mytext);
              return "b" + c(arg1, "b is calling");
            }

            function c(arg1) {
              return "c" + a(arg1, "c is calling");
            }
            """
          fileName : "testFile.js"
          testString : "a('anArg'); a('anArg', 'anArg');"

        when "parameterCheck"
          string : """
            function fn(p1, p2, p3) {}
          """
          fileName : "parameterCheck.js"
          testString : "fn('aString for p1', { obj : 'for p2'})"

        when "function expression"
          string : "var someObj = { fn : function() { console.log('someObj was invoked')} }"
          fileName : "object.js"
          testString : "someObj.fn();"

    callHistoryData = generateCallHistoryData(getTestCase())

    DOMroot = document.getElementById('main')
    React.renderComponent(
      App {callHistoryData}
      DOMroot
    )
