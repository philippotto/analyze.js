### define
react : React
react-bootstrap : ReactBootstrap
with_react : withReact
hljs : hljs
###

R = withReact.R
classSet = React.addons.classSet

CodeView = React.createClass

  render : ->

    className = classSet(
      "code-view" : true
      "invisible" : !@props.data?
    )

    code = if @props.data? then @props.data.getSourceString() else ""

    R.div {className, ref : "codeView"},
      R.pre {},
        R.code {className : "javascript"}
          code


  highlightBlock : ->

    hljs.highlightBlock(@refs.codeView.getDOMNode())

  componentDidMount : -> @highlightBlock()

  componentDidUpdate : -> @highlightBlock()

