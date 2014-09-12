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

  immutableCode = ""
  getTestCase = ->
    testcase = "immutable"
    switch testcase
      when "immutable"
        string : immutableCode
        fileURL : "immutable.js"
        testString : "map = Immutable.Map({a : 1, b : 2, c : 3}); map.set('d', 4)"

      when "simpleCallHierarchy"
        string : """
          function a(arg1, callee) {
            if (callee == null)
              return "a" + b(arg1, "a is calling");
            return "a";
          }

          function b(arg1) {
            var mytext=document.createTextNode("dynamically inserted text");
            console.log("going to change the dom");
            document.body.appendChild(mytext);
            return "b" + c(arg1, "b is calling");
          }

          function c(arg1) {
            return "c" + a(arg1, "c is calling");
          }
          """
        fileURL : "testFile.js"
        testString : "a('anArg'); a('anArg', 'anArg');"

      when "parameterCheck"
        string : """
          function fn(p1, p2, p3) {}
        """
        fileURL : "parameterCheck.js"
        testString : "fn('aString for p1', { obj : 'for p2'})"

      when "function expression"
        string : "var someObj = { fn : function() { console.log('someObj was invoked')} }"
        fileURL : "object.js"
        testString : "someObj.fn();"



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
