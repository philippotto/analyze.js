### define
react : React
react-bootstrap : ReactBootstrap
with_react : withReact
./object_viewer : ObjectViewer
../Formatter : Formatter
./variable_view : VariableView
###

R = withReact.R
eval(withReact.import)

Invocation = React.createClass

  render : ->

    invocation = @props.invocation
    jsFunction = invocation.jsFunction

    if invocation.isRoot
      return div {}

    popoverOverlay = Popover {title: "Arguments"},
      ObjectViewer { object : invocation.getViewableArguments() }

    formattedArguments = @getFormattedArguments(invocation)

    onDoubleClick = => @props.setCurrentFunction(jsFunction)

    div {className : "invocation", style : @getStyle(), onDoubleClick},
      div className : "pull-right",
        div onClick : @logInvocation,
          span className : "file-name",
            Formatter.extractNameFromFileURL(jsFunction.getFileURL())
          @getTimeMarker(invocation)
      div {},
        @getToggler()
        span className : "function-name",
          jsFunction.getName()
        span {},
          OverlayTrigger {trigger: "click", placement: "right", overlay : popoverOverlay},
            span {},
              "("
              formattedArguments
              ")"
        span {onClick : -> console.log(invocation.getReturnValue())},
          span className : "return-arrow",
            " → "
          new VariableView(data : invocation.getReturnValue())
        Label {className : "offsetted-label", bsStyle: "default", onClick : -> console.log(invocation.getContext())},
          "context"
        span {className: "offsetted-label"},
          if invocation.changesDOM() then Label bsStyle: "warning", "Changes DOM"


  getFormattedArguments : (invocation) ->

    invocation.getArguments().map((arg) ->
      new VariableView(data : arg)
    ).reduce(
      (acc, el, index, array) ->
        acc.push(span {key : "arg-" + index}, el)
        if index < array.length - 1
          acc.push(span {key : "arg-," + index}, ", ")
        acc
      []
    )


  formatTime : (t) -> t.toFixed(2) + " ms"

  getTimeMarker: (invocation) ->

    timeTooltip = Tooltip {},
      div {}, "Total time: " + @formatTime invocation.getTotalTime()
      div {}, "Pure time: " + @formatTime invocation.getPureTime()

    OverlayTrigger {trigger: "hover", placement: "left", overlay : timeTooltip},
      div className : "circle pull-right " + if invocation.getTotalTime() > 0 then "slow" else "fast"


  getToggler : ->

    invocation = @props.invocation

    if invocation.hasChildren()
      div {
        className: "triangle " + if invocation.isCollapsed then "closed" else "open"
        ref : "collapseToggler"
        onClick : =>
          invocation.toggleCollapsing()
          @props.forceUpdate()
      }


  getStyle : ->

    return {
      "margin-left": 15 * (@props.invocation.level + 1)
    }


  logInvocation : ->

    console.log("invocation",  @props.invocation)


  componentDidMount : -> @props.invocation.setDirty(false)

  componentDidUpdate : -> @props.invocation.setDirty(false)

