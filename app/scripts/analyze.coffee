### define
react : React
react-bootstrap : ReactBootstrap
with_react : withReact
instrumentation/CallGraph : CallGraph
instrumentation/Tracer : Tracer
views/object_viewer : ObjectViewer
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

        console.time("renderComponent")
        React.renderComponent(
          AppView {callHistoryData}
          document.getElementById("main")
        )
        console.timeEnd("renderComponent")
      500
      leading : true
    )
  )
