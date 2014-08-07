### define
falafel : falafel
react : React
foundation : Foundation
###

->
  $(document).foundation()

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



  if not localStorage.getItem("comments")

    localStorage.setItem("comments", JSON.stringify([
      {author: "Pete Hunt", text: "This is one comment"}
      {author: "Jordan Walke", text: "This is *another* comment"}
    ]))


  addComment = (author, text) ->

    comments = localStorage.getItem("comments")
    comments = JSON.parse(comments)
    comments.push({author, text})

    comments = JSON.stringify(comments)
    localStorage.setItem("comments", comments)

  removeComment = ->

    comments = localStorage.getItem("comments")
    comments = JSON.parse(comments)
    comments.splice(-1)

    comments = JSON.stringify(comments)
    localStorage.setItem("comments", comments)

  R = React.DOM


  # CommentBox
  #   CommentList
  #     Comment
  #   CommentForm

  CommentBox = React.createClass(

    getInitialState : ->
      data : []

    handleCommentRemove : (author, text) ->

      removeComment()
      @setState data : JSON.parse localStorage.getItem("comments")

    handleCommentSubmit : ({author, text}) ->
      addComment(author, text)
      @setState data : JSON.parse localStorage.getItem("comments")


    componentDidMount : ->
      @setState data : JSON.parse localStorage.getItem("comments")
      # setInterval(=>
      #   @setState data : JSON.parse localStorage.getItem("comments")
      # , @props.pollInterval)

    render : ->
      R.div {className : "commentBox"},
        CommentList {data : @state.data, onCommentRemove : @handleCommentRemove}
        CommentForm {onCommentSubmit : @handleCommentSubmit}
  )

  CommentList = React.createClass(
    render : ->
      commentNodes = @props.data.map (comment) =>
        Comment {author : comment.author, onCommentRemove : @props.onCommentRemove}, comment.text

      R.div {className : "commentList"},
        commentNodes
  )

  Comment = React.createClass(
    remove : ->
      console.log("remove", arguments)
      @props.onCommentRemove(@props.author, @props.children.toString())

    render : ->
      rawMarkup = this.props.children.toString()

      R.div {className : "comment"},
        R.h2 {className : "commentAuthor", onClick : @remove}, @props.author
        R.span {dangerouslySetInnerHTML : { __html : rawMarkup}}
        R.a {href : "#", onClick : @remove}, "Remove"
  )


  CommentForm = React.createClass(
    handleSubmit : (evt) ->
      author = @refs.author.getDOMNode().value
      text = @refs.text.getDOMNode().value

      @props.onCommentSubmit({author, text})

      @refs.author.getDOMNode().value = ''
      @refs.text.getDOMNode().value = ''

      return false

    render : ->
      R.form {className : "commentForm", onSubmit : @handleSubmit},
        R.input {ref : "author", type : "text", placeholder : "Your name"}
        R.input {ref : "text", type : "text", placeholder : "Say something..."}
        R.input {type : "submit", value : "Post"}
  )


  DOMroot = document.getElementById('main')

  React.renderComponent(
    CommentBox {url : "comment.json", pollInterval : 100}
    DOMroot
  )
