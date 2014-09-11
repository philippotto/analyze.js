### define
react : React
react-bootstrap : ReactBootstrap
with_react : withReact
object_viewer : ObjectViewer

###

R = withReact.R

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
