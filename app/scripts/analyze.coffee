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

  # delay in order to avoid mysterious race conditions
  # (sometimes analyzee cannot access window.app)
  _.delay(
    ->
      analyzee = window.open("", "analyzee")

      forceRefresh = true

      if forceRefresh or analyzee.location.href == "about:blank"
        analyzee.location.href = document.location.origin

      analyzee.focus()
    1000
  )

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
      maxWait : 60000
    )
  )
