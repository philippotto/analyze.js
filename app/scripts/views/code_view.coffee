### define
react : React
react-bootstrap : ReactBootstrap
with_react : withReact
hljs : hljs
###

R = withReact.R

CodeView = React.createClass

  render : ->

    code = if @props.data? then @props.data.getSourceString() else ""

    R.div {className : "code-view javascript", ref : "codeView"},
      R.pre {},
        R.code {}
          code


  highlightBlock : ->

    hljs.highlightBlock(@refs.codeView.getDOMNode())

  componentDidMount : -> @highlightBlock()

  componentDidUpdate : -> @highlightBlock()

  shouldComponentUpdate : (nextProps, nextState) ->

    console.log("@props.data != nextProps.data",  @props.data != nextProps.data)
    @props.data != nextProps.data
