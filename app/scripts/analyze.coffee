### define
react : React
react-bootstrap : ReactBootstrap
with_react : withReact
object_viewer : ObjectViewer
instrumentation/CallGraph : CallGraph
instrumentation/Tracer : Tracer
views/app_view : AppView
###

->

  app.tracer = new Tracer(new CallGraph(), true)
  analyzee = window.open("", "analyzee")

  forceRefresh = true

  if forceRefresh or analyzee.location.href == "about:blank"
    analyzee.location.href = document.location.origin

  analyzee.focus()

  app.commands.setHandler(
    "renderCallGraph"
    _.debounce(
      =>
        callHistoryData = app.tracer.getRoot()

        React.renderComponent(
          AppView {callHistoryData}
          document.getElementById("main")
        )
      500
      leading : true
    )
  )
