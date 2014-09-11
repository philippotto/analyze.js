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

  $.ajax("Immutable.js", {dataType: "text"}).then (immutableCode) ->

    getTestCase = ->
      testcase = "immutable"
      switch testcase
        when "immutable"
          string : immutableCode
          fileName : "immutable.js"
          testString : "map = Immutable.Map({a : 1, b : 2, c : 3}); map.set('d', 4)"

        when "simpleCallHierarchy"
          string : """
            function a(arg1, callee) {
              if (callee == null)
                return "a" + b(arg1, "a is calling");
              return "a";
            }

            function b(arg1) {
              var mytext=document.createTextNode("some text");
              console.log("going to change the dom");
              document.body.appendChild(mytext);
              return "b" + c(arg1, "b is calling");
            }

            function c(arg1) {
              return "c" + a(arg1, "c is calling");
            }
            """
          fileName : "testFile.js"
          testString : "a('anArg'); a('anArg', 'anArg');"

        when "parameterCheck"
          string : """
            function fn(p1, p2, p3) {}
          """
          fileName : "parameterCheck.js"
          testString : "fn('aString for p1', { obj : 'for p2'})"

        when "function expression"
          string : "var someObj = { fn : function() { console.log('someObj was invoked')} }"
          fileName : "object.js"
          testString : "someObj.fn();"


    setTimeout(
      =>
        callHistoryData = callGraph.root

        DOMroot = document.getElementById('main')
        React.renderComponent(
          AppView {callHistoryData}
          DOMroot
        )
      5000
    )


  window.callGraph = new CallGraph()
  window.tracer = new Tracer(window.callGraph, true)

  window.analyzee = analyzee = window.open("", "analyzee")

  if analyzee.location.href == "about:blank"
    analyzee.location.href = document.location.origin

  analyzee.focus()
