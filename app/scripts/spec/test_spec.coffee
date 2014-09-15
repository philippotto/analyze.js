### define
../instrumentation/Instrumenter : Instrumenter

###

describe("Instrumenter", ->
  it("runs", ->
    console.log("require",  require)
    instrumenter = new Instrumenter()
    instrumentedCode = instrumenter.instrument("function a() { return true }", "aFileURL")

    console.log("instrumentedCode",  instrumentedCode)

    expect(instrumentedCode).toNotBe(null)

  )
)
