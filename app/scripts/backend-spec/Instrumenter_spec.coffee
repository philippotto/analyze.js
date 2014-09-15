Instrumenter = require("../instrumentation/Instrumenter.js")
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

    [window, called, protocol] = getBasicTracer(called, protocol)

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
    [window, called, protocol] = getBasicTracer(called, protocol)


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

)
