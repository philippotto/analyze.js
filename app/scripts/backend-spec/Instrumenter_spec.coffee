Instrumenter = require("../backend/instrumenter.js")
instrumenter = new Instrumenter()


getBasicTracer = ->

  called = []
  protocol = {}
  window =
    opener:
      app:
        tracer:
          traceEnter : (id, props, args, ctx) ->
            called.push("enter")
            protocol.enter = {id, props, args, ctx}
          traceExit : (id, returnValue, thrownExeption) ->
            called.push("exit")
            protocol.exit = {id, returnValue, thrownExeption}

  return [window, called, protocol]


describe("Instrumenter", ->
  it("provides basic instrumentation information", ->
    fnCode = """
    function aFunctionName(p1, p2) {
      return true;
    }
    """
    ctxMock = {}
    startCode = 'aFunctionName.call(ctxMock, "arg1");'

    fileURL = "aFileURL"
    instrumentedCode = instrumenter.instrument(fnCode, fileURL)

    [window, called, protocol] = getBasicTracer()

    try
      eval(instrumentedCode)
      eval(startCode)
    catch e
      console.log("exception while eval",  e)

    expect(called).toEqual(["enter", "exit"])
    expect(protocol.enter.id).toContain("aFunctionName")
    expect(protocol.enter.args).toEqual(["arg1"])
    expect(protocol.enter.ctx).toEqual(ctxMock)

    expect(protocol.enter.props.fileURL).toEqual(fileURL)
    expect(protocol.enter.props.source).toEqual(fnCode)
    expect(protocol.enter.props.name).toEqual("aFunctionName")
    expect(protocol.enter.props.params).toEqual(["p1", "p2"])

    expect(protocol.enter.id).toBe(protocol.exit.id)
    expect(protocol.exit.returnValue).toEqual(true)
  )

  it("can track a thrown exception", ->

    fnCode = """
    function aThrowingFunction() {
      throw Exception("a exception");
    }
    """
    startCode = "aThrowingFunction()"

    instrumentedCode = instrumenter.instrument(fnCode, "")
    [window, called, protocol] = getBasicTracer()


    bubbledException = null

    try
      eval(instrumentedCode)
      eval(startCode)
    catch e
      bubbledException = e

    expect(called).toEqual(["enter", "exit"])
    expect(bubbledException).toNotEqual(null)
    expect(protocol.exit.thrownExeption).toNotEqual(null)
    expect(protocol.exit.thrownExeption).toEqual(bubbledException)

  )

  it("can handle different function naming conventions", ->

    fnCode = """
    function a() {};
    var b = function() {};
    var bb = function() {}.bind(this);
    var obj = {
      c : function() {},
      d : function() { var d; }.bind(this)
    }
    var caller = function(cb) { cb(); };
    var callNamed = function() {
      caller(function namedFunction() {});
    };
    var callAnonymous = function() {
      caller(function() {});
    };
    """

    instrumentedCode = instrumenter.instrument(fnCode, "")

    eval(instrumentedCode)
    [window, called, protocol] = getBasicTracer()


    eval("a()")
    expect(protocol.enter.props.name).toBe("a")

    eval("b()")
    expect(protocol.enter.props.name).toBe("b")

    eval("bb()")
    expect(protocol.enter.props.name).toBe("bb")

    eval("obj.c()")
    expect(protocol.enter.props.name).toBe("c")

    eval("obj.d()")
    expect(protocol.enter.props.name).toBe("d")

    eval("callNamed()")
    expect(protocol.enter.props.name).toBe("namedFunction")

    # TODO:
    # It would probably be nice to get the name "cb". But this would require
    # instrumenting every function call. For now anonymousFn should be enough.

    eval("callAnonymous()")
    expect(protocol.enter.props.name).toBe("anonymousFn")
  )

  it("can get the original source of nested functions", ->

    code = """
    function a() {
      function b() {};
    }
    """

    instrumentedCode = instrumenter.instrument(code, "")

    eval(instrumentedCode)
    [window, called, protocol] = getBasicTracer()

    eval("a()")

    expect(protocol.enter.props.source).toNotContain("traceEnter")
  )

)
