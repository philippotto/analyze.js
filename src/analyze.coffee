window.FunctionStore =

  functions : []

  getOrCreateFunctionByID : (id, params) ->

    unless @functions[id]

      @functions[id] = new JSFunction(id, params)

    return @functions[id]


class JSFunction

  constructor : (@id, @params) ->



class InvocationNode

  constructor : (@jsFunction, @params, @context) ->
    @children = []
    @startTime = performance.now()

  addChild : (child) ->
    @children.push child
    child.parent = @

  stopInvocation : ->
    @endTime = performance.now()

  getTime : ->
    @endTime - @startTime


class CallGraph

  constructor : ->
    @root = new InvocationNode()
    @root.isRoot = true
    @activeNode = @root

  pushInvocation : (invocationNode) ->

    @activeNode.addChild(invocationNode)
    invocationNode.parent = @activeNode
    @activeNode = invocationNode

  popInvocation : ->

    @activeNode.stopInvocation()
    @activeNode = @activeNode.parent



class Tracer
  traceEnter : (id, params, context) ->

    jsFunction = FunctionStore.getOrCreateFunctionByID(id)
    invocationNode = new InvocationNode(jsFunction, params, context)

    callGraph.pushInvocation invocationNode

    console.log "traceEnter was triggered", arguments

  traceExit : (id) ->
    console.log "traceExit was triggered", arguments
    callGraph.popInvocation()


window.tracer = new Tracer()
window.callGraph = new CallGraph()




createID = (fileName, fnName, range) ->

  Array.prototype.join.call(arguments, "-")


src =
  string : "function hello(name) { console.log('hello', name); if(name == 'philipp') { hello('tom'); } }"
  fileName : "testFile.js"

window.output = falafel(src.string, (node) ->
  console.log "node", node

  parent = node.parent

  # first two parts of condition could be enough?
  if parent and parent.type is "FunctionDeclaration" and node.type is "BlockStatement"
    fnID = "'" + createID(src.fileName, parent.id.name, parent.id.range) + "'"
    jsFunction = FunctionStore.getOrCreateFunctionByID(fnID, parent.params)
    node.update "{\ntracer.traceEnter(" + fnID + ", arguments, this);\n" + node.source() + ";\ntracer.traceExit(" + fnID + ");\n}"

)

eval(output.toString())
console.log(hello("philipp"), "hi  2")
console.log(hello("hans"), "hi  2")

makeIndent = (n) ->
  new Array(n * 2).join(" ")

printCallGraph = (node, indention = 0) ->

  node.children.forEach((child) ->
    console.log(makeIndent(indention), child)
    printCallGraph(child, indention + 1)
  )

console.log("printing callGraph")
printCallGraph(callGraph.root)



R = React.DOM

CommentForm = React.createClass(
  render : ->
    R.div {className : "commentForm"},
      "Hello, world! I am a CommentBox."
)


CommentList = React.createClass(
  render : ->
    R.div {className : "commentList"},
      "CommentList."
)

CommentBox = React.createClass(
  render : ->
    R.div {className : "commentBox"},
      R.h1 null, "Comments"
      CommentList()
      CommentForm()

)


React.renderComponent(
  CommentBox({}),
  document.getElementById('content')
);