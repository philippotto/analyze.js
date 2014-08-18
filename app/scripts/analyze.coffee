### define
falafel : falafel
react : React
foundation : Foundation
###

->
  $(document).foundation()

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
      return @jsFunction.getName().indexOf(query) > -1


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

  console.log("callGraph", callGraph)



  callHistoryData = callGraph.root


  # ################################################################################################
  # ################################################## React #######################################
  # ################################################################################################

  # CallHistory
  #   InvocationContainer
  #     Invocation

  R = React.DOM

  CallHistory = React.createClass

    getInitialState : ->
      rootInvocation : {
        children : []
        isRoot : true,
        searchQuery : ""
      }

    componentDidMount : ->
      @setState rootInvocation : callHistoryData, searchQuery : ""

      window.testFn = (p) =>
        @setState rootInvocation : callHistoryData, searchQuery : p


    render : ->
      R.div {className : "call-history"},
        InvocationContainer {invocation : @state.rootInvocation, searchQuery : @state.searchQuery}


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

      div {className : "panel invocation", onClick : @logInvocation},
        div {className : "pull-right"},
          jsFunction.getFileName()
          div {},
            span {className: "alert label pull-right"}, invocation.getFormattedTime()
        h4 {}, name
        div {}, "Arguments: " + invocation.getFormattedArguments()

        div {},
          a href : '#', "data-dropdown" : "dropID", ref : "dataDropdown",
            'Function'
        div id : "dropID", "data-dropdown-content" : true, className : "f-dropdown content", ref : "dropdownContent",
          p 'Some text that people will think is awesome! Some text that people will think is awesome! Some text that people will think is awesome!'

    logInvocation : ->

      console.log("invocation",  @props.invocation)


  DOMroot = document.getElementById('main')
  React.renderComponent(
    CallHistory {url : "invocation.json"}
    DOMroot
  )
